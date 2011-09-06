Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin",{
    extend:"Ext.ux.desktop.Module",
    id:'rails_db_admin-win',

    queriesTreePanel : function(){
        return this.accordion.query('.railsdbadmin_queriestreemenu')[0];
    },

    setWindowStatus : function(status){
        this.window.setStatus(status);
    },

    clearWindowStatus : function(){
        this.window.clearStatus();
    },

    getTableData : function(table){
        var database = this.getDatabase();
		
        var grid = new Compass.ErpApp.Shared.DynamicEditableGridLoaderPanel({
            title:table,
            setupUrl:'/rails_db_admin/base/setup_table_grid/' + table,
            dataUrl:'/rails_db_admin/base/table_data/' + table,
            editable:true,
            page:true,
            pageSize:25,
            displayMsg:'Displaying {0} - {1} of {2}',
            emptyMsg:'Empty',
            loadErrorMessage:'Tables Without Ids Can Not Be Edited',
            closable:true,
            params:{
                database:database
            }
        });

        this.container.add(grid);
        this.container.setActiveTab(this.container.items.length - 1);
    },

    selectTopFifty : function(table){
        this.setWindowStatus('Selecting Top 50 from '+ table +'...');
        var database = this.getDatabase();
        var self = this;

        var conn = new Ext.data.Connection();
        conn.request({
            url: '/rails_db_admin/queries/select_top_fifty/' + table,
            timeout:60000,
            params:{
                database:database
            },
            success: function(responseObject) {
                self.clearWindowStatus();
                var response =  Ext.decode(responseObject.responseText);
                var sql = response.sql;
                var columns = response.columns;
                var fields = response.fields;
                var data = response.data;

                var readOnlyDataGrid = new Compass.ErpApp.Desktop.Applications.RailsDbAdmin.ReadOnlyTableDataGrid({
                    columns:columns,
                    fields:fields,
                    data:data
                });

                var queryPanel = new Compass.ErpApp.Desktop.Applications.RailsDbAdmin.QueryPanel({
                    module:self,
                    sqlQuery:sql
                });
				
                self.container.add(queryPanel);
                self.container.setActiveTab(self.container.items.length - 1);
		
                queryPanel.gridContainer.add(readOnlyDataGrid);
                queryPanel.gridContainer.getLayout().setActiveItem(0);
            },
            failure: function() {
                self.clearWindowStatus();
                Ext.Msg.alert('Status', 'Error loading grid');
            }
        });
    },

    addNewQueryTab : function(){
        this.container.add({
            xtype:'railsdbadmin_querypanel',
            module:this
        });
        this.container.setActiveTab(this.container.items.length - 1);
    },

    connectToDatatbase : function(){
        var database = Ext.getCmp('databaseCombo').getValue();
        var tablestreePanelStore = this.accordion.query('.railsdbadmin_tablestreemenu')[0].store;
        var queriesTreePanelStore = this.accordion.query('.railsdbadmin_queriestreemenu')[0].store;

        tablestreePanelStore.setProxy({
            type: 'ajax',
            url: '/rails_db_admin/base/tables',
            extraParams:{
                database:database
            }
        });
        tablestreePanelStore.load();

        queriesTreePanelStore.setProxy({
            type: 'ajax',
            url: '/rails_db_admin/queries/saved_queries_tree',
            extraParams:{
                database:database
            }
        });
        queriesTreePanelStore.load();
    },

    getDatabase : function(){
        var database = Ext.get('databaseCombo').getValue();
        return database;
    },
	
    deleteQuery : function(queryName){
        this.setWindowStatus('Deleting '+ queryName +'...');
        var self = this;
        var database = this.getDatabase();
        var conn = new Ext.data.Connection();
        conn.request({
            url: '/rails_db_admin/queries/delete_query/',
            params:{
                database:database,
                query_name:queryName
            },
            success: function(responseObject) {
                self.clearWindowStatus();
                var response =  Ext.decode(responseObject.responseText);
                if(response.success)
                {
                    Ext.Msg.alert('Error', 'Query deleted');
                    var queriesTreePanelStore = self.accordion.query('.railsdbadmin_queriestreemenu')[0].store;
                    queriesTreePanelStore.setProxy({
                        type: 'ajax',
                        url: '/rails_db_admin/queries/saved_queries_tree',
                        extraParams:{
                            database:database
                        }
                    });
                    queriesTreePanelStore.load();
                }
                else
                {
                    Ext.Msg.alert('Error', response.exception);
                }
				
            },
            failure: function() {
                self.clearWindowStatus();
                Ext.Msg.alert('Status', 'Error deleting query');
            }
        });
    },
	
    displayAndExecuteQuery : function(queryName){
        this.setWindowStatus('Executing '+ queryName +'...');
        var self = this;
        var database = this.getDatabase();
        var conn = new Ext.data.Connection();
        conn.request({
            url: '/rails_db_admin/queries/open_and_execute_query/',
            params:{
                database:database,
                query_name:queryName
            },
            success: function(responseObject) {
                var response =  Ext.decode(responseObject.responseText);
                var query = response.query;
				
                var queryPanel = null;
				
                if(response.success)
                {
                    self.clearWindowStatus();
                    var columns = response.columns;
                    var fields = response.fields;
                    var data = response.data;

                    var readOnlyDataGrid = new Compass.ErpApp.Desktop.Applications.RailsDbAdmin.ReadOnlyTableDataGrid({
                        columns:columns,
                        fields:fields,
                        data:data
                    });

                    queryPanel = new Compass.ErpApp.Desktop.Applications.RailsDbAdmin.QueryPanel({
                        module:self,
                        sqlQuery:query
                    });
					
                    self.container.add(queryPanel);
                    self.container.setActiveTab(self.container.items.length - 1);
					
                    queryPanel.gridContainer.add(readOnlyDataGrid);
                    queryPanel.gridContainer.getLayout().setActiveItem(0);
                }
                else
                {
                    Ext.Msg.alert('Error', response.exception);
                    queryPanel = new Compass.ErpApp.Desktop.Applications.RailsDbAdmin.QueryPanel({
                        module:self,
                        sqlQuery:query
                    });
					
                    self.container.add(queryPanel);
                    self.container.setActiveTab(self.container.items.length - 1);
                }
				
            },
            failure: function() {
                self.clearWindowStatus();
                Ext.Msg.alert('Status', 'Error loading query');
            }
        });
    },

    init : function(){
        this.launcher = {
            text: 'RailsDbAdmin',
            iconCls:'icon-rails_db_admin',
            handler : this.createWindow,
            scope: this
        }
    },

    createWindow : function(){
        var self = this;
        var desktop = this.app.getDesktop();
        var win = desktop.getWindow('rails_db_admin');
        if(!win){
            this.container = new Ext.TabPanel({
                region : 'center',
                margins : '0 0 0 0',
                minsize : 300
            });

            this.accordion = new Ext.Panel({
                region : 'west',
                margins : '0 0 0 0',
                cmargins : '0 0 0 0',
                width : 300,
                collapsible: true,
                layout: 'accordion',
                items:[
                {
                    xtype:'railsdbadmin_tablestreemenu',
                    module:this
                },

                {
                    xtype:'railsdbadmin_queriestreemenu',
                    module:this
                }
                ]
            });

            win = desktop.createWindow({
                id: 'rails_db_admin',
                title:'RailsDBAdmin',
                autoDestroy:true,
                width:1200,
                height:550,
                iconCls: 'icon-rails_db_admin',
                shim:false,
                animCollapse:false,
                constrainHeader:true,
                layout: 'border',
                tbar:{
                    items:[
                    {
                        text:'Database:'
                    },
                    {
                        xtype:'railsdbadmin_databasecombo',
                        module: self
                    }
                    ]
                },
                items:[this.accordion, this.container]
            });

            this.window = win;
        }
        win.show();
    }
});
