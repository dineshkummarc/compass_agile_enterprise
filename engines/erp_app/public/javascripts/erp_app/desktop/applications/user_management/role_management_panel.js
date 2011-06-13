Compass.ErpApp.Desktop.Applications.UserManagement.RoleManagementPanel = Ext.extend(Ext.Panel, {
    setWindowStatus : function(status){
        this.findParentByType('statuswindow').setStatus(status);
    },
    
    clearWindowStatus : function(){
        this.findParentByType('statuswindow').clearStatus();
    },

    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.UserManagement.RoleManagementPanel.superclass.initComponent.call(this, arguments);
    },

    loadTrees :function(){
        var treePanels = this.findByType('treepanel');
        Ext.each(treePanels, function(tree){
            tree.getRootNode().reload();
        });
    },

    addAllAvailableRoles : function(){
        var availableRolesRoot = this.findById('role_mgt_available_roles').getRootNode();
        var currentRolesRoot = this.findById('role_mgt_current_roles').getRootNode();

        availableRolesRoot.eachChild(function(node) {
            var atts = node.attributes;
            atts.id = node.id;
            atts.text = node.text;
            currentRolesRoot.appendChild(new Ext.tree.TreeNode(Ext.apply({}, atts)));
        });

        availableRolesRoot.removeAll(true);
    },

    removeAllCurrentRoles : function(){
        var availableRolesRoot = this.findById('role_mgt_available_roles').getRootNode();
        var currentRolesRoot = this.findById('role_mgt_current_roles').getRootNode();

        currentRolesRoot.eachChild(function(node) {
            var atts = node.attributes;
            atts.id = node.id;
            atts.text = node.text;
            availableRolesRoot.appendChild(new Ext.tree.TreeNode(Ext.apply({}, atts)));
        });

        currentRolesRoot.removeAll(true);
    },

    saveRoles : function(){
        var roleIds = []
        var treePanel = this.findById('role_mgt_current_roles');
        var treeRoot = treePanel.getRootNode();
        this.setWindowStatus('Saving...');

        treeRoot.eachChild(function(node) {
            roleIds.push(node.id);
        });

        var rolesJson = {
            "role_ids":roleIds,
            "user_id":this.initialConfig['userId']
        };

        var conn = new Ext.data.Connection();
        var self = this;
        conn.request({
            url: './user_management/role_management/save_roles',
            method: 'PUT',
            jsonData:rolesJson,
            success: function(responseObject) {
                self.clearWindowStatus();
                Compass.ErpApp.Utility.promptReload();
            },
            failure: function() {
                self.clearWindowStatus();
                Ext.Msg.alert('Status', 'Unable To Save Roles. Please Try Agian Later.');
            }
        });

        
    },

    constructor : function(config) {
        var available_roles_tree = new Ext.tree.TreePanel({
            id:'role_mgt_available_roles',
            animate:false,
            autoScroll:true,
            region:'west',
            loader: new Ext.tree.TreeLoader({
                dataUrl:'./user_management/role_management/available_roles',
                baseParams:{
                    user_id:config['userId']
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
                        this.addAllAvailableRoles();
                    }
                }
                ]
            },
            root:new Ext.tree.AsyncTreeNode({
                text: 'Available Roles',
                draggable:false
            })
        });
        
        var current_roles_tree = new Ext.tree.TreePanel({
            id:'role_mgt_current_roles',
            animate:false,
            region:'center',
            autoScroll:true,
            loader: new Ext.tree.TreeLoader({
                dataUrl:'./user_management/role_management/current_roles',
                baseParams:{
                    user_id:config['userId']
                }
            }),
            root:new Ext.tree.AsyncTreeNode({
                text: 'Current Roles',
                draggable:false
            }),
            tbar:{
                items:[
                {
                    text:'Remove All',
                    iconCls:'icon-delete',
                    scope:this,
                    handler:function(){
                        this.removeAllCurrentRoles();
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
                    this.saveRoles();
                }
            }
            ]
        });

        config = Ext.apply({
            layout:'border',
            title:'Roles',
            items:[available_roles_tree,current_roles_tree]
        }, config);


        Compass.ErpApp.Desktop.Applications.UserManagement.RoleManagementPanel.superclass.constructor.call(this, config);
    }
});

Ext.reg('usermanagement_rolemanagementpanel', Compass.ErpApp.Desktop.Applications.UserManagement.RoleManagementPanel);
