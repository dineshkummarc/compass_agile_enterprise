Compass.ErpApp.Desktop.Applications.UserManagement.UserApplicationMgtPanel = Ext.extend(Ext.Panel, {
    setWindowStatus : function(status){
        this.findParentByType('statuswindow').setStatus(status);
    },

    clearWindowStatus : function(){
        this.findParentByType('statuswindow').clearStatus();
    },

    loadTrees :function(){
        var treePanels = this.findByType('treepanel');
        Ext.each(treePanels, function(tree){
            tree.getRootNode().reload();
        });
    },

    addAllAvailableApplications : function(){
        var availableRolesRoot = this.available_applications_tree.getRootNode();
        var currentRolesRoot = this.current_applications_tree.getRootNode();

        availableRolesRoot.eachChild(function(node) {
            var atts = node.attributes;
            atts.id = node.id;
            atts.text = node.text;
            currentRolesRoot.appendChild(new Ext.tree.TreeNode(Ext.apply({}, atts)));
        });

        availableRolesRoot.removeAll(true);
    },

    removeAllCurrentApplications : function(){
        var availableRolesRoot = this.available_applications_tree.getRootNode();
        var currentRolesRoot = this.current_applications_tree.getRootNode();

        currentRolesRoot.eachChild(function(node) {
            var atts = node.attributes;
            atts.id = node.id;
            atts.text = node.text;
            availableRolesRoot.appendChild(new Ext.tree.TreeNode(Ext.apply({}, atts)));
        });

        currentRolesRoot.removeAll(true);
    },

    saveApplications : function(){
        var appIds = []
        var treePanel = this.current_applications_tree;
        var treeRoot = treePanel.getRootNode();
        var savingLabel = Ext.get('user_managment_saving_label');
        this.setWindowStatus('Saving...');

        treeRoot.eachChild(function(node) {
            appIds.push(node.id);
        });

        var rolesJson = {
            "app_ids":appIds,
            "app_container_type":this.initialConfig['appContainerType'],
            "user_id":this.initialConfig['userId']
        };

        var conn = new Ext.data.Connection();
        var self = this;
        conn.request({
            url: './user_management/application_management/save_applications',
            method: 'PUT',
            jsonData:rolesJson,
            success: function(responseObject) {
                self.clearWindowStatus();
                Ext.MessageBox.confirm('Confirm', 'Page must reload for changes to take affect. Reload now?', function(btn){
                    if(btn == 'no'){
                        return false;
                    }
                    else{
                        window.location.reload();
                    }
                });
            },
            failure: function() {
                self.clearWindowStatus();
                Ext.Msg.alert('Status', 'Unable To Save Applications. Please Try Agian Later.');
            }
        });
    },

    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.UserManagement.UserApplicationMgtPanel.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        this.available_applications_tree = new Ext.tree.TreePanel({
            animate:false,
            autoScroll:true,
            region:'west',
            loader: new Ext.tree.TreeLoader({
                dataUrl:'./user_management/application_management/available_applications',
                baseParams:{
                    user_id:config['userId'],
                    app_container_type:config['appContainerType']
                    }
            }),
            enableDD:true,
            containerScroll: true,
            border: false,
            width: 250,
            height: 300,
            frame:true,
            enableDrop:false,
            tbar:{
                items:[
                {
                    text:'Add All',
                    iconCls:'icon-add',
                    scope:this,
                    handler:function(){
                        this.addAllAvailableApplications();
                    }
                }
                ]
            },
            root:new Ext.tree.AsyncTreeNode({
                text: 'Available Applications',
                draggable:false
            })
        });

        this.current_applications_tree = new Ext.tree.TreePanel({
            animate:false,
            region:'center',
            autoScroll:true,
            loader: new Ext.tree.TreeLoader({
                dataUrl:'./user_management/application_management/current_applications',
                baseParams:{
                    user_id:config['userId'],
                    app_container_type:config['appContainerType']
                    }
            }),
            root:new Ext.tree.AsyncTreeNode({
                text: 'Current Applications',
                draggable:false
            }),
            tbar:{
                items:[
                {
                    text:'Remove All',
                    iconCls:'icon-delete',
                    scope:this,
                    handler:function(){
                        this.removeAllCurrentApplications();
                    }
                }
                ]
            },
            enableDD:true,
            containerScroll: true,
            border: false,
            frame:true,
            width: 250,
            height: 300,
            buttons:[
            {
                text:'save',
                scope:this,
                handler:function(){
                    this.saveApplications();
                }
            }
            ]
        });

        config = Ext.apply({
            layout:'border',
            items:[this.available_applications_tree,this.current_applications_tree]
        }, config);

        Compass.ErpApp.Desktop.Applications.UserManagement.UserApplicationMgtPanel.superclass.constructor.call(this, config);
    }
});

Ext.reg('controlpanel_userapplicationmgtpanel', Compass.ErpApp.Desktop.Applications.UserManagement.UserApplicationMgtPanel);



