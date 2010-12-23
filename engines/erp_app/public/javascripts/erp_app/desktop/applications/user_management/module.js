Ext.ns("Compass.ErpApp.Desktop.Applications");

Compass.ErpApp.Desktop.Applications.UserManagement = Ext.extend(Ext.app.Module, {
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
                width:1000,
                height:550,
                iconCls: 'icon-user',
                shim:false,
                animCollapse:false,
                constrainHeader:true,
                layout: 'border',
                items:[{
                    xtype:'usermanagement_usersgrid',
                    tabPanel:tabPanel,
                    widgets:this.initialConfig['widgets']
                },tabPanel]
            });
        }
        win.show();
    }
});

Compass.ErpApp.Desktop.Applications.UserManagement.UsersGrid = Ext.extend(Ext.grid.GridPanel, {
    initComponent: function() {
        this.store.load();

        Compass.ErpApp.Desktop.Applications.UserManagement.UsersGrid.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        var tabPanel = config['tabPanel']
        var users_store = new Ext.data.JsonStore({
            root:'data',
            url:'user_management/users/',
            baseParams:{
                login:null
            },
            fields:[
            {
                name:'id'
            },{
                name:'login'
            },{
                name:'email'
            },{
                name:'enabled'
            }
            ]
        });

        config = Ext.apply({
            width:375,
            region:'west',
            store:users_store,
            columns:[
            {
                header:'Login',
                dataIndex:'login',
                width:150
            },
            {
                header:'Email',
                dataIndex:'email',
                width:150
            },
            {
                header:'Enabled',
                dataIndex:'enabled',
                width:50
            }
            ],
            tbar:{
                items:[
                {
                    xtype:'textfield',
                    hideLabel:true,
                    id:'user_search_field'
                },
                {
                    text: 'Search',
                    iconCls: 'icon-search',
                    handler: function(button) {
                        var login = Ext.getCmp('user_search_field').getValue();
                        users_store.setBaseParam('login',login);
                        users_store.load();
                    }
                },
                '->',
                {
                    html:'<span id="user_managment_saving_label" style="visibility:hidden;color:white;font-weight:bold;padding-right:5px;">Saving...</span>'
                }
                ]
            },
            bbar:new Ext.PagingToolbar({
                pageSize: 30,
                store: users_store,
                displayInfo: true,
                displayMsg: 'Displaying {0} - {1} of {2}',
                emptyMsg: "No Users"
            }),
            listeners:{
                'rowclick':function(grid, rowIndex){
                    var messageBox = Ext.Msg.wait('Loading..', 'Loading User...')
                    var record = grid.getStore().getAt(rowIndex);
                    var userId = record.get('id');
                    var conn = new Ext.data.Connection();
                    conn.request({
                        url: 'user_management/users/get_details/' + userId,
                        params:{},
                        success: function(responseObject) {
                            var response =  Ext.util.JSON.decode(responseObject.responseText);
                            tabPanel.removeAll(true);
                            if(grid.initialConfig['widgets'].contains('usermanagement_personalinfopanel')){
                                tabPanel.add(
                                {
                                    xtype:'usermanagement_personalinfopanel',
                                    entityInfo:response.entityInfo,
                                    entityType:response.entityType
                                });
                            }
                            if(grid.initialConfig['widgets'].contains('usermanagement_rolemanagementpanel')){
                                tabPanel.add(
                                {
                                    xtype:'usermanagement_rolemanagementpanel',
                                    userId:userId,
                                    listeners:{
                                        'activate':function(){
                                            this.loadTrees();
                                        }
                                    }
                                });
                            }
                            if(grid.initialConfig['widgets'].contains('controlpanel_userapplicationmgtpanel')){
                                tabPanel.add(
                                {
                                    xtype:'controlpanel_userapplicationmgtpanel',
                                    userId:userId,
                                    title:'Desktop Applications',
                                    appContainerType:'Desktop',
                                    listeners:{
                                        'activate':function(){
                                            this.loadTrees();
                                        }
                                    }
                                });
                                tabPanel.add(
                                {
                                    xtype:'controlpanel_userapplicationmgtpanel',
                                    userId:userId,
                                    appContainerType:'Organizer',
                                    title:'Organizer Applications',
                                    listeners:{
                                        'activate':function(){
                                            this.loadTrees();
                                        }
                                    }
                                });
                            }
                            tabPanel.setActiveTab(0);
                            messageBox.hide();
                        },
                        failure: function() {
                            messageBox.hide();
                            Ext.Msg.alert('Status', 'Error loading User');
                        }
                    });
                }
            }
        }, config);

        Compass.ErpApp.Desktop.Applications.UserManagement.UsersGrid.superclass.constructor.call(this, config);
    }
});

Ext.reg('usermanagement_usersgrid', Compass.ErpApp.Desktop.Applications.UserManagement.UsersGrid);


