Ext.define("Compass.ErpApp.Desktop.Applications.SystemManagement.ApplicationRoleManagementPanel",{
    extend:"Ext.Panel",
    alias:'widget.systemmanagement_applicationrolemanagement',
    setWindowStatus : function(status){
        this.findParentByType('statuswindow').setStatus(status);
    },
    
    clearWindowStatus : function(){
        this.findParentByType('statuswindow').clearStatus();
    },

    selectModel :function(id, klass){
        this.modelId = id;
        this.klass = klass;

        this.availableRolesTreeStore.setProxy({
                type: 'ajax',
                url: '/erp_app/desktop/system_management/application_role_management/available_roles',
                extraParams:{
                    id:id,
                    klass:klass
                }
        });
        this.availableRolesTreeStore.load();
        this.availableRolesTree.getRootNode().expand();

        this.currentRolesTreeStore.setProxy({
                type: 'ajax',
                url: '/erp_app/desktop/system_management/application_role_management/current_roles',
                extraParams:{
                    id:id,
                    klass:klass
                }
        });
        this.currentRolesTreeStore.load();
        this.availableRolesTree.getRootNode().expand();
    },

    addAllAvailableRoles : function(){
        var availableRolesRoot = this.availableRolesTree.getRootNode();
        var currentRolesRoot = this.currentRolesTree.getRootNode();

        availableRolesRoot.eachChild(function(node) {
            currentRolesRoot.appendChild(node.copy());
        });

        availableRolesRoot.removeAll(true);
    },

    removeAllCurrentRoles : function(){
        var availableRolesRoot = this.availableRolesTree.getRootNode();
        var currentRolesRoot = this.currentRolesTree.getRootNode();

        currentRolesRoot.eachChild(function(node) {
            availableRolesRoot.appendChild(node.copy());
        });

        currentRolesRoot.removeAll(true);
    },

    saveRoles : function(){
        if(!Compass.ErpApp.Utility.isBlank(this.modelId)){
            var roleIds = [];
            var treeRoot = this.currentRolesTree.getRootNode();
            this.setWindowStatus('Saving...');

            treeRoot.eachChild(function(node) {
                roleIds.push(node.data.role_id);
            });

            var rolesJson = {
                "role_ids":roleIds,
                "id":this.modelId,
                "klass":this.klass
            };

            var self = this;
            Ext.Ajax.request({
                url: '/erp_app/desktop/system_management/application_role_management/save_roles',
                method: 'PUT',
                jsonData:rolesJson,
                success: function(responseObject) {
                    self.clearWindowStatus();
                    Compass.ErpApp.Utility.promptReload();
                },
                failure: function() {
                    Ext.Msg.alert('Status', 'Unable To Save Roles. Please Try Agian Later.');
                }
            });
        }
    },

    constructor : function(config) {
        var applicationsTreeStore = Ext.create('Ext.data.TreeStore', {
            proxy: {
                type: 'ajax',
                url: '/erp_app/desktop/system_management/application_role_management/applications'
            },
            root: {
                text: 'Applications',
                expanded: true,
                draggable:false
            },
            fields:[
                {name:'text'},
                {name:'iconCls'},
                {name:'modelId'},
                {name:'leaf'},
                {name:'hasRoles'},
                {name:'klass'}
            ]
        });
        
        var applicationsTree = new Ext.tree.TreePanel({
            store:applicationsTreeStore,
            animate:false,
            autoScroll:true,
            region:'west',
            containerScroll: true,
            border: false,
            width: 500,
            height: 300,
            frame:true,
            listeners:{
                scope:this,
                'itemclick':function(view, record){
                    if(record.data.hasRoles)
                    {
                        this.selectModel(record.data.modelId, record.data.klass);
                    }
                }
            }
        });

        this.availableRolesTreeStore = Ext.create('Ext.data.TreeStore', {
            autoLoad:false,
            proxy: {
                type: 'ajax',
                url: '/erp_app/desktop/system_management/application_role_management/available_roles'
            },
            root: {
                text: 'Available Roles',
                draggable:false,
                expanded:true
            },
            fields:[
                {name:'text'},
                {name:'iconCls'},
                {name:'role_id'},
                {name:'leaf'}
            ]

        });

        this.availableRolesTree = new Ext.tree.TreePanel({
            store:this.availableRolesTreeStore,
            id:'app_roles_mgt_available_roles',
            animate:false,
            autoScroll:true,
            region:'west',
            containerScroll: true,
            border: false,
            width: 250,
            height: 300,
            frame:true,
            viewConfig: {
                plugins: {
                    ptype: 'treeviewdragdrop'
                }
            },
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
            }
        });

        this.currentRolesTreeStore = Ext.create('Ext.data.TreeStore', {
            proxy: {
                type: 'ajax',
                url: '/erp_app/desktop/system_management/application_role_management/current_roles'
            },
            root: {
                text: 'Current Roles',
                draggable:false,
                expanded:true
            },
            fields:[
                {name:'text'},
                {name:'iconCls'},
                {name:'role_id'},
                {name:'leaf'}
            ]
        });

        this.currentRolesTree = new Ext.tree.TreePanel({
            store:this.currentRolesTreeStore,
            id:'app_roles_mgt_current_roles',
            region:'center',
            animate:false,
            autoScroll:true,
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
                }
                ]
            },
            viewConfig: {
                plugins: {
                    ptype: 'treeviewdragdrop'
                }
            },
            containerScroll: true,
            border: false,
            frame:false
        });

        var rolesPanel = new Ext.Panel({
            layout:'border',
            items:[this.availableRolesTree, this.currentRolesTree],
            region:'center'
        })

        config = Ext.apply({
            layout:'border',
            title:'Applications',
            items:[applicationsTree,rolesPanel]
        }, config);

        this.callParent([config]);
    }
});

