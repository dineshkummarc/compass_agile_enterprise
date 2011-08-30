Ext.define("Compass.ErpApp.Desktop.Applications.UserManagement",{
    extend:"Ext.ux.desktop.Module",
    id:'user-management-win',
    init : function(){
        this.launcher = {
            text: 'User Management',
            iconCls:'icon-user',
            handler : this.createWindow,
            scope: this
        }
    },
    createWindow : function(){
        var desktop = this.app.getDesktop();
        var win = desktop.getWindow('user_management');
        if(!win){
            var tabPanel = new Ext.TabPanel({
                region:'center'
            });
            win = desktop.createWindow({
                id: 'user_management',
                title:'User Management',
                width:1100,
                height:550,
                iconCls: 'icon-user',
                shim:false,
                animCollapse:false,
                constrainHeader:true,
                layout: 'border',
                items:[{
                    xtype:'usermanagement_usersgrid',
                    tabPanel:tabPanel,
                    widget_roles:this.widget_roles
                },tabPanel]
            });
        }
        win.show();
    }
});

Ext.define("Compass.ErpApp.Desktop.Applications.UserManagement.UsersGrid",{
    extend:"Ext.grid.Panel",
    alias:'widget.usermanagement_usersgrid',
    setWindowStatus : function(status){
        this.findParentByType('statuswindow').setStatus(status);
    },
    
    clearWindowStatus : function(){
        this.findParentByType('statuswindow').clearStatus();
    },

    deleteUser : function(rec){
        var self = this;
        self.setWindowStatus('Deleting user...');
        var conn = new Ext.data.Connection();
        conn.request({
            url: '/erp_app/desktop/user_management/users/delete/' + rec.get("id"),
            method: 'POST',
            success: function(response) {
                var obj =  Ext.decode(response.responseText);
                if(obj.success){
                    self.clearWindowStatus();
                    self.getStore().load();
                }
                else{
                    Ext.Msg.alert('Error', 'Error deleting user.');
                    self.clearWindowStatus();
                }
            },
            failure: function(response) {
                self.clearWindowStatus();
                Ext.Msg.alert('Error', 'Error deleting user.');
            }
        });
    },

    updatePassword : function(rec){
        var self = this;
        var updatePasswordWindow = new Ext.Window({
            layout:'fit',
            width:375,
            title:'Update Password',
            height:130,
            plain: true,
            buttonAlign:'center',
            items: new Ext.FormPanel({
                labelWidth: 110,
                frame:false,
                bodyStyle:'padding:5px 5px 0',
                width: 425,
                url: '/erp_app/desktop/user_management/users/update_user_password/' + rec.get("id"),
                defaults: {
                    width: 225
                },
                items: [
                {
                    xtype:'textfield',
                    fieldLabel:'New Password',
                    allowBlank:false,
                    name:'password',
                    inputType: 'password'
                },
                {
                    xtype:'textfield',
                    fieldLabel:'Confirm Password',
                    allowBlank:false,
                    name:'password_confirmation',
                    inputType: 'password'
                }
                ]
            }),
            buttons: [{
                text:'Submit',
                listeners:{
                    'click':function(button){
                        var window = button.findParentByType('window');
                        var formPanel = window.query('form')[0];
                        self.setWindowStatus('Updating password ...');
                        formPanel.getForm().submit({
                            reset:true,
                            success:function(form, action){
                                self.clearWindowStatus();
                                var obj =  Ext.decode(action.response.responseText);
                                if(!obj.success){
                                    Ext.Msg.alert("Error", obj.msg);
                                }
                                updatePasswordWindow.close();
                            },
                            failure:function(form, action){
                                self.clearWindowStatus();
                                var obj =  Ext.decode(action.response.responseText);
                                if(Compass.ErpApp.Utility.isBlank(obj.message)){
                                    Ext.Msg.alert("Error", 'Error updating password.');
                                }
                                else{
                                    Ext.Msg.alert("Error", obj.message);
                                }
                            }
                        });
                    }
                }
            },{
                text: 'Close',
                handler: function(){
                    updatePasswordWindow.close();
                }
            }]
        });
        updatePasswordWindow.show();
    },

    viewUser : function(rec){
        this.setWindowStatus('Loading User...');
        var conn = new Ext.data.Connection();
        var userId = rec.get('id');
        var self = this;
        conn.request({
            url: '/erp_app/desktop/user_management/users/get_details/' + userId,
            params:{},
            success: function(responseObject) {
                var response = Ext.decode(responseObject.responseText);
                self.tabPanel.removeAll();

                if(ErpApp.Authentication.RoleManager.hasAccessToWidget(self.widget_roles, "shared_notesgrid"))
                {
                    self.initialConfig.tabPanel.add(
                    {
                        xtype:'shared_notesgrid',
                        partyId:rec.get('party_id'),
                        title:'Notes'
                    });
                }

                if(ErpApp.Authentication.RoleManager.hasAccessToWidget(self.widget_roles, "usermanagement_personalinfopanel"))
                {
                    self.initialConfig.tabPanel.add(
                    {
                        xtype:'usermanagement_personalinfopanel',
                        entityInfo:response.entityInfo,
                        entityType:response.entityType
                    });
                }

                if(ErpApp.Authentication.RoleManager.hasAccessToWidget(self.widget_roles, "usermanagement_rolemanagementpanel"))
                {
                    self.initialConfig.tabPanel.add(
                    {
                        xtype:'usermanagement_rolemanagementpanel',
                        userId:userId
                    });
                }

                if(ErpApp.Authentication.RoleManager.hasAccessToWidget(self.widget_roles, "controlpanel_userapplicationmgtpanel"))
                {
                    self.initialConfig.tabPanel.add(
                    {
                        xtype:'controlpanel_userapplicationmgtpanel',
                        userId:userId,
                        title:'Desktop Applications',
                        appContainerType:'Desktop'
                    });
                    self.initialConfig.tabPanel.add(
                    {
                        xtype:'controlpanel_userapplicationmgtpanel',
                        userId:userId,
                        appContainerType:'Organizer',
                        title:'Organizer Applications'
                    });
                }
                self.initialConfig.tabPanel.setActiveTab(0);
                self.clearWindowStatus('Loading User...');
            },
            failure: function() {
                self.clearWindowStatus('Loading User...');
                Ext.Msg.alert('Status', 'Error loading User');
            }
        });
    },

    initComponent: function() {
        this.store.load();
        Compass.ErpApp.Desktop.Applications.UserManagement.UsersGrid.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        var self = this;

        var usersStore = Ext.create('Ext.data.Store', {
            proxy: {
                type: 'ajax',
                url : '/erp_app/desktop/user_management/users/',
                reader: {
                    idProperty: 'id',
                    totalProperty:'totalCount',
                    type: 'json',
                    root: 'data'
                }
            },
            remoteSort:true,
            fields:[
            {
                name: 'id',
                type: 'int'
            },
            {
                name:'party_id',
                type:'int'
            },
            {
                name: 'username',
                type: 'string'
            },
            {
                name: 'email',
                type: 'string'
            }
            ]
        });
         
        var columns = [{
            header:'Username',
            dataIndex:'username',
            width:150
        },
        {
            header:'Email',
            dataIndex:'email',
            width:150
        },
        {
            menuDisabled:true,
            resizable:false,
            xtype:'actioncolumn',
            align:'center',
            width:50,
            items:[{
                icon:'/images/icons/document_view/document_view_16x16.png',
                tooltip:'View',
                handler :function(grid, rowIndex, colIndex){
                    var rec = grid.getStore().getAt(rowIndex);
                    self.viewUser(rec);
                }
            }]
        }];

        if(ErpApp.Authentication.RoleManager.hasRole('admin')){
            columns.push({
                menuDisabled:true,
                resizable:false,
                xtype:'actioncolumn',
                align:'center',
                width:50,
                items:[{
                    icon:'/images/icons/edit/edit_16x16.png',
                    tooltip:'Update Password',
                    handler :function(grid, rowIndex, colIndex){
                        var rec = grid.getStore().getAt(rowIndex);
                        self.updatePassword(rec);
                    }
                }]
            });
        }

        if(ErpApp.Authentication.RoleManager.hasRole('admin')){
            columns.push({
                menuDisabled:true,
                resizable:false,
                xtype:'actioncolumn',
                align:'center',
                width:50,
                items:[{
                    icon:'/images/icons/delete/delete_16x16.png',
                    tooltip:'Delete',
                    handler :function(grid, rowIndex, colIndex){
                        Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this user?', function(btn){
                            if(btn == 'no'){
                                return false;
                            }
                            else
                            if(btn == 'yes')
                            {
                                var rec = grid.getStore().getAt(rowIndex);
                                self.deleteUser(rec);
                            }
                        });
                    }
                }]
            });
        }

        var toolBarItems = [];
        if(ErpApp.Authentication.RoleManager.hasRole('admin')){
            toolBarItems.push({
                text:'Add User',
                iconCls:'icon-add',
                handler:function(){
                    var addUserWindow = Ext.create("Ext.window.Window",{
                        width:325,
                        title:'New User',
                        height:270,
                        plain: true,
                        buttonAlign:'center',
                        items: {
                            xtype:'form',
                            frame:false,
                            bodyStyle:'padding:5px 5px 0',
                            url:'/erp_app/desktop/user_management/users/new',
                            defaults: {
                                width: 225,
                                labelWidth: 100
                            },
                            items: [
                            {
                                emptyText:'Select Gender...',
                                xtype: 'combo',
                                forceSelection:true,
                                store: [['m','Male'],['f','Female']],
                                fieldLabel: 'Gender',
                                name: 'gender',
                                allowBlank: false,
                                triggerAction: 'all'

                            },
                            {
                                xtype:'textfield',
                                fieldLabel:'First Name',
                                allowBlank:false,
                                name:'first_name'
                            },
                            {
                                xtype:'textfield',
                                fieldLabel:'Last Name',
                                allowBlank:false,
                                name:'last_name'
                            },
                            {
                                xtype:'textfield',
                                fieldLabel:'Email',
                                allowBlank:false,
                                name:'email'
                            },
                            {
                                xtype:'textfield',
                                fieldLabel:'Login',
                                allowBlank:false,
                                name:'login'
                            },
                            {
                                xtype:'textfield',
                                fieldLabel:'Password',
                                inputType: 'password',
                                allowBlank:false,
                                name:'password'
                            },
                            {
                                xtype:'textfield',
                                fieldLabel:'Confirm Password',
                                inputType: 'password',
                                allowBlank:false,
                                name:'password_confirmation'
                            }
                            ]
                        },
                        buttons: [{
                            text:'Submit',
                            listeners:{
                                'click':function(button){
                                    var window = button.findParentByType('window');
                                    var formPanel = window.query('.form')[0];
                                    self.setWindowStatus('Creating user...');
                                    formPanel.getForm().submit({
                                        reset:true,
                                        success:function(form, action){
                                            self.clearWindowStatus();
                                            var obj =  Ext.decode(action.response.responseText);
                                            if(obj.success){
                                                self.getStore().load();
                                            }
                                            else{
                                                Ext.Msg.alert("Error", obj.message);
                                            }
                                        },
                                        failure:function(form, action){
                                            self.clearWindowStatus();
                                            if(action.response !== undefined){
                                                var obj =  Ext.decode(action.response.responseText);
                                                Ext.Msg.alert("Error", obj.message);
                                            }
                                            else{
                                                Ext.Msg.alert("Error", 'Error adding user.');
                                            }
                                        }
                                    });
                                }
                            }
                        },{
                            text: 'Close',
                            handler: function(){
                                addUserWindow.close();
                            }
                        }]
                    });
                    addUserWindow.show();
                }
            });
        }
        toolBarItems.push('|');
        toolBarItems.push({
            xtype:'textfield',
            hideLabel:true,
            id:'user_search_field'
        });
        toolBarItems.push({
            text: 'Search',
            iconCls: 'icon-search',
            handler: function(button) {
                var login = Ext.getCmp('user_search_field').getValue();
                usersStore.setProxy({
                    type: 'ajax',
                    url: '/erp_app/desktop/user_management/users/',
                    reader: {
                        type: 'json',
                        root: 'data',
                        idProperty: 'id',
                        totalProperty:'totalCount'
                    },
                    extraParams:{
                        login:login
                    }
                });
                usersStore.loadPage(1);
            }
        });

        config = Ext.apply({
            width:460,
            region:'west',
            store:usersStore,
            loadMask:false,
            columns:columns,
            tbar:{
                items:toolBarItems
            },
            bbar: Ext.create("Ext.toolbar.Paging",{
                pageSize: 25,
                store: usersStore,
                displayInfo: true,
                displayMsg: 'Displaying {0} - {1} of {2}',
                emptyMsg: "No Users"
            })
        }, config);

        Compass.ErpApp.Desktop.Applications.UserManagement.UsersGrid.superclass.constructor.call(this, config);
    }
});
