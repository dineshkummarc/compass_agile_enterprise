Compass.RailsDbAdmin.QueryPanel = Ext.extend(Ext.Panel, {
    gridContainer : null,

    initComponent: function() {
        var self = this;
        var messageBox = null;
		
        var savedQueriesJsonStore = new Ext.data.JsonStore({
            url:'./queries/saved_queries',
            root:'data',
            baseParams:{
                database:null
            },
            fields:[
            {
                name:'value'
            },
            {
                name:'display'
            }
            ],
            listeners:{
                'beforeload':function(store){
                    var database = window.RailsDbAdmin.getDatabase();
                    store.setBaseParam('database', database);
                }
            }
        });

        var tableGridContainer = new Ext.Panel({
            layout:'card',
            region : 'center',
            margins : '0 0 0 0',
            autoScroll:true,
            items:[]
        });

        this.gridContainer = tableGridContainer;

        var textAreaPanel = new Ext.Panel({
            height:300,
            region:'north',
            margins : '0 0 0 0',
            autoScroll:true,
            layout:'fit',
            items:[
            {
                xtype : 'textarea',
                value : '' || this.initialConfig['query']
            }
            ]
        });
		
        this.tbar = {
            items:[{
                text: 'Execute',
                iconCls: 'icon-settings',
                handler: function(button) {
                    var textarea = self.findByType('textarea')[0];
                    var sql = textarea.getValue();
                    var database = window.RailsDbAdmin.getDatabase();
					
                    messageBox = Ext.Msg.wait('Status', 'Executing..');

                    var conn = new Ext.data.Connection();
                    conn.request({
                        url: './queries/execute_query',
                        params:{
                            sql:sql,
                            database:database
                        },
                        method:'post',
                        success: function(responseObject) {

                            messageBox.hide();
                            var response =  Ext.util.JSON.decode(responseObject.responseText);

                            if(response.success)
                            {
                                var columns = response.columns;
                                var fields = response.fields;
                                var data = response.data;

                                var grid = new Compass.RailsDbAdmin.ReadOnlyTableDataGrid({
                                    columns:columns,
                                    fields:fields,
                                    data:data
                                });

                                tableGridContainer.removeAll(true);
                                tableGridContainer.add(grid);
                                tableGridContainer.getLayout().setActiveItem(0);
                            }
                            else
                            {
                                Ext.Msg.alert("Error", response.exception);
                            }

                        },
                        failure: function() {
                            messageBox.hide();
                            Ext.Msg.alert('Status', 'Error loading grid');
                        }
                    });
                }
            },
            {
                text: 'Save',
                iconCls: 'icon-save',
                handler:function(){
                    var textarea = self.findByType('textarea')[0];
                    var save_window = new Ext.Window({
                        layout:'fit',
                        width:375,
                        title:'Save Query',
                        height:125,
                        buttonAlign:'center',
                        closeAction:'hide',
                        plain: true,
                        items: new Ext.FormPanel({
                            frame:false,
                            bodyStyle:'padding:5px 5px 0',
                            width: 500,
                            items: [{
                                xtype: 'combo',
                                fieldLabel: 'Query Name',
                                name: 'query_name',
                                allowBlank:false,
                                store:savedQueriesJsonStore,
                                valueField:'value',
                                displayField:'display',
                                triggerAction:'all',
                                forceSelection:false,
                                mode:'remote'
                            },
                            {
                                xtype: 'hidden',
                                value: textarea.getValue(),
                                name: 'query'
                            },
                            {
                                xtype: 'hidden',
                                value: window.RailsDbAdmin.getDatabase(),
                                name: 'database'
                            }]
                        }),
                        buttons: [{
                            text: 'Save',
                            handler: function(){
                                var fp = this.findParentByType('window').findByType('form')[0];
                                if(fp.getForm().isValid()){
                                    fp.getForm().submit({
                                        url: './queries/save_query',
                                        waitMsg: 'Saving Query...',
                                        success: function(fp, o){
                                            Ext.Msg.alert('Success', 'Saved Query');
                                            var queryTreePanel = window.RailsDbAdmin.QueriesTreePanel;
                                            queryTreePanel.treePanel.getLoader().baseParams.database = window.RailsDbAdmin.getDatabase();
                                            queryTreePanel.treePanel.getRootNode().reload();
                                            save_window.hide();
                                        }
                                    });
                                }
                            }
                        },{
                            text: 'Cancel',
                            handler: function(){
                                save_window.hide();
                            }
                        }]
						
                    });
                    save_window.show();
                }
            }]
        };

        this.items = [textAreaPanel, tableGridContainer]
		
        Compass.RailsDbAdmin.QueryPanel.superclass.initComponent.call(this, arguments);
    },
    constructor : function(config) {
        config = Ext.apply({
            title:'Query',
            layout:'border',
            autoScroll:true,
            closable: true,
            border:false
        }, config);
        Compass.RailsDbAdmin.QueryPanel.superclass.constructor.call(this, config);
    }
	
});

Ext.reg('querypanel', Compass.RailsDbAdmin.QueryPanel);