Ext.ns("Compass.RailsDbAdmin");

Compass.RailsDbAdmin.Main = function(organizerLayout, tablestreePanel, queriesTreePanel){

    this.TablesTreePanel = tablestreePanel;
    this.QueriesTreePanel = queriesTreePanel;

    var messageBox = null;

    var container = new Ext.TabPanel({
        region : 'center',
        margins : '0 0 0 0',
        minsize : 300
    });

    this.getTableData = function(table){
        var database = this.getDatabase();
		
        var grid = new Compass.ErpApp.Shared.DynamicEditableGridLoaderPanel({
            title:table,
            setupUrl:'./base/setup_table_grid/' + table,
            dataUrl:'./base/table_data/' + table,
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

        container.add(grid);
        container.setActiveTab(container.items.length - 1);
    };

    this.selectTopFifty = function(table){
        messageBox = Ext.Msg.wait('Status', 'Selecting Top 50 from '+ table +'...');
        var database = this.getDatabase();
		
        var conn = new Ext.data.Connection();
        conn.request({
            url: './queries/select_top_fifty/' + table,
            timeout:60000,
            params:{
                database:database
            },
            success: function(responseObject) {
                
                var response =  Ext.util.JSON.decode(responseObject.responseText);
                var sql = response.sql;
                var columns = response.columns;
                var fields = response.fields;
                var data = response.data;

                var readOnlyDataGrid = new Compass.RailsDbAdmin.ReadOnlyTableDataGrid({
                    columns:columns,
                    fields:fields,
                    data:data
                });

                var queryPanel = new Compass.RailsDbAdmin.QueryPanel({
                    query:sql
                });
				
                container.add(queryPanel);
                container.setActiveTab(container.items.length - 1);
		
                queryPanel.gridContainer.add(readOnlyDataGrid);
                queryPanel.gridContainer.getLayout().setActiveItem(0);

                messageBox.hide();
            },
            failure: function() {
                messageBox.hide();
                Ext.Msg.alert('Status', 'Error loading grid');
            }
        });
    };

    this.addNewQueryTab = function(){
        container.add({
            xtype:'querypanel'
        });
        container.setActiveTab(container.items.length - 1);
    };

    this.connectToDatatbase = function(){
        var database = Ext.get('databaseCombo').getValue();
        tablestreePanel.treePanel.getLoader().baseParams.database = database;
        tablestreePanel.treePanel.getRootNode().reload();
        queriesTreePanel.treePanel.getLoader().baseParams.database = database;
        queriesTreePanel.treePanel.getRootNode().reload();
    };

    this.getDatabase = function(){
        var database = Ext.get('databaseCombo').getValue();
        return database;
    }
	
    this.deleteQuery = function(queryName){
        messageBox = Ext.Msg.wait('Status', 'Deleting '+ queryName +'...');
        var database = this.getDatabase();
		
        var conn = new Ext.data.Connection();
        conn.request({
            url: './queries/delete_query/',
            params:{
                database:database,
                query_name:queryName
            },
            success: function(responseObject) {
                
                messageBox.hide();
                var response =  Ext.util.JSON.decode(responseObject.responseText);
                var query = response.query;
				
                var queryPanel = null;
				
                if(response.success)
                {
                    Ext.Msg.alert('Error', 'Query deleted');
                    var queriesTreePanel = window.RailsDbAdmin.QueriesTreePanel;
                    queriesTreePanel.treePanel.getLoader().baseParams.database = database;
                    queriesTreePanel.treePanel.getRootNode().reload();
                }
                else
                {
                    Ext.Msg.alert('Error', response.exception);
                }
				
            },
            failure: function() {
                messageBox.hide();
                Ext.Msg.alert('Status', 'Error loading grid');
            }
        });
    };
	
    this.displayAndExecuteQuery = function(queryName){
        messageBox = Ext.Msg.wait('Status', 'Executing '+ queryName +'...');
        var database = this.getDatabase();
		
        var conn = new Ext.data.Connection();
        conn.request({
            url: './queries/open_and_execute_query/',
            params:{
                database:database,
                query_name:queryName
            },
            success: function(responseObject) {
                
                messageBox.hide();

                var response =  Ext.util.JSON.decode(responseObject.responseText);
                var query = response.query;
				
                var queryPanel = null;
				
                if(response.success)
                {
                    var columns = response.columns;
                    var fields = response.fields;
                    var data = response.data;

                    var readOnlyDataGrid = new Compass.RailsDbAdmin.ReadOnlyTableDataGrid({
                        columns:columns,
                        fields:fields,
                        data:data
                    });

                    queryPanel = new Compass.RailsDbAdmin.QueryPanel({
                        query:query
                    });
					
                    container.add(queryPanel);
                    container.setActiveTab(container.items.length - 1);
					
                    queryPanel.gridContainer.add(readOnlyDataGrid);
                    queryPanel.gridContainer.getLayout().setActiveItem(0);
					
                }
                else
                {
                    Ext.Msg.alert('Error', response.exception);
                    queryPanel = new Compass.RailsDbAdmin.QueryPanel({
                        query:query
                    });
					
                    container.add(queryPanel);
                    container.setActiveTab(container.items.length - 1);
                }
				
            },
            failure: function() {
                messageBox.hide();
                Ext.Msg.alert('Status', 'Error loading query');
            }
        });
    }

    this.Container = container;
};


