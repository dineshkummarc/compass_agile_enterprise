Ext.ns("Compass.ErpApp.Desktop.Applications.SystemManagement");

Compass.ErpApp.Desktop.Applications.SystemManagement.ApplcationRoleManagementPanel = Ext.extend(Ext.Panel, {

    selectWidget :function(id){
        this.widgetId = id;
        this.available_roles_tree.getLoader().baseParams.id = id;
        this.available_roles_tree.getRootNode().reload();
        this.current_roles_tree.getLoader().baseParams.id = id;
        this.current_roles_tree.getRootNode().reload();
    },

    addAllAvailableRoles : function(){
        var availableRolesRoot = this.available_roles_tree.getRootNode();
        var currentRolesRoot = this.current_roles_tree.getRootNode();

        availableRolesRoot.eachChild(function(node) {
            var atts = node.attributes;
            atts.id = node.id;
            atts.text = node.text;
            currentRolesRoot.appendChild(new Ext.tree.TreeNode(Ext.apply({}, atts)));
        });

        availableRolesRoot.removeAll(true);
    },

    removeAllCurrentRoles : function(){
        var availableRolesRoot = this.available_roles_tree.getRootNode();
        var currentRolesRoot = this.current_roles_tree.getRootNode();

        currentRolesRoot.eachChild(function(node) {
            var atts = node.attributes;
            atts.id = node.id;
            atts.text = node.text;
            availableRolesRoot.appendChild(new Ext.tree.TreeNode(Ext.apply({}, atts)));
        });

        currentRolesRoot.removeAll(true);
    },

    saveRoles : function(){
        if(!Compass.ErpApp.Utility.isBlank(this.widgetId)){
            var roleIds = []
            var treePanel = this.current_roles_tree;
            var treeRoot = treePanel.getRootNode();
            var savingLabel = Ext.get('app_role_mgt_saving_label');
            savingLabel.applyStyles('visibility:visible');

            treeRoot.eachChild(function(node) {
                roleIds.push(node.id);
            });

            var rolesJson = {
                "role_ids":roleIds,
                "id":this.widgetId
            };

            var conn = new Ext.data.Connection();
            conn.request({
                url: './system_management/application_role_management/save_roles',
                method: 'PUT',
                jsonData:rolesJson,
                success: function(responseObject) {
                    savingLabel.applyStyles('visibility:hidden');
                },
                failure: function() {
                    Ext.Msg.alert('Status', 'Unable To Save Roles. Please Try Agian Later.');
                }
            });
        }
    },

    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.SystemManagement.ApplcationRoleManagementPanel.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        var applications_tree = new Ext.tree.TreePanel({
            animate:false,
            autoScroll:true,
            region:'west',
            loader: new Ext.tree.TreeLoader({
                dataUrl:'./system_management/application_role_management/applications'
            }),
            enableDD:true,
            containerScroll: true,
            border: false,
            width: 250,
            height: 300,
            frame:true,
            enableDrop:false,
            root:new Ext.tree.AsyncTreeNode({
                text: 'Applications',
                draggable:false
            }),
            listeners:{
                scope:this,
                'click':function(node){
                    if(node.attributes['leaf'])
                    {
                        this.selectWidget(node.id);
                    }
                }
            }
        });

        this.available_roles_tree = new Ext.tree.TreePanel({
            id:'app_roles_mgt_available_roles',
            animate:false,
            autoScroll:true,
            loader: new Ext.tree.TreeLoader({
                baseParams:{
                    id:0
                },
                dataUrl:'./system_management/application_role_management/available_roles'
            }),
            region:'west',
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

        this.current_roles_tree = new Ext.tree.TreePanel({
            id:'app_roles_mgt_current_roles',
            region:'center',
            animate:false,
            autoScroll:true,
            loader: new Ext.tree.TreeLoader({
                baseParams:{
                    id:0
                },
                dataUrl:'./system_management/application_role_management/current_roles'
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
                },
                {
                    text:'save',
                    scope:this,
                    iconCls:'icon-save',
                    handler:function(){
                        this.saveRoles();
                    }
                },
                {
                    html:'<span id="app_role_mgt_saving_label" style="visibility:hidden;color:white;font-weight:bold;padding-left:5px;">Saving...</span>'
                }
                ]
            },
            enableDD:true,
            containerScroll: true,
            border: false,
            frame:true,
            width: 250,
            height: 300
        });

        var rolesPanel = new Ext.Panel({
            layout:'border',
            items:[this.available_roles_tree, this.current_roles_tree],
            region:'center'
        })

        config = Ext.apply({
            layout:'border',
            title:'Applications',
            items:[applications_tree,rolesPanel]
        }, config);

        Compass.ErpApp.Desktop.Applications.SystemManagement.ApplcationRoleManagementPanel.superclass.constructor.call(this, config);
    }
});

Ext.reg('systemmanagement_applicationrolemanagment', Compass.ErpApp.Desktop.Applications.SystemManagement.ApplcationRoleManagementPanel);



