
Compass.RailsDbAdmin.EditableTableDataGrid = Ext.extend(Ext.grid.GridPanel, {
    initComponent: function() {
        var messageBox = null;
		
        var database = window.RailsDbAdmin.getDatabase();
		
        var proxy = new Ext.data.HttpProxy({
            url: './base/table_data/' + this.initialConfig['table']
        });

        proxy.addListener('exception', function(proxy, type, action, options, res) {
            var message = 'Error in processing request';
            if(!Compass.ErpApp.Utility.isBlank(res.message))
                message = res.message;
            Ext.Msg.alert('Error', message);
        });

        proxy.addListener('beforewrite', function(proxy, action) {
            if(messageBox != null)
                messageBox.hide();

            var messageBox = Ext.Msg.wait('Status', 'Sending request...');
        });

        proxy.addListener('write', function(dataProxy, action, data, response, rs, options) {
            var message = "Request processed"

            if(messageBox != null)
                messageBox.hide();

            rs.dirty = false;
            rs.commit();

            if(!Compass.ErpApp.Utility.isBlank(response.message))
                message = response.message;

            Ext.Msg.alert('Status', message);
        });

        var reader = new Ext.data.JsonReader({
            successProperty: 'success',
            totalProperty:'totalCount',
            idProperty: 'id',
            root: 'data',
            messageProperty: 'message'
        },
        this.initialConfig['fields']);

        var writer = new Ext.data.JsonWriter({
            encode: false
        });

        var store = new Ext.data.Store({
            restful: true,
            proxy: proxy,
            reader: reader,
            writer: writer,
            baseParams:{
                database:database
            },
            listeners:{
                'exception':function(){
                    var message = 'Error in processing request';

                    if(!Compass.ErpApp.Utility.isBlank(arguments[5]))
                        message = arguments[5];

                    Ext.Msg.alert("Error", message);
                }
            }
        });

        this.store = store;

        this.bbar = new Ext.PagingToolbar({
            pageSize: 30,
            store: store,
            displayInfo: true,
            displayMsg: 'Displaying {0} - {1} of {2}',
            emptyMsg: "No Data"
        })

        Compass.RailsDbAdmin.EditableTableDataGrid.superclass.initComponent.call(this, arguments);
    },
    constructor : function(config) {
        var editor = new Ext.ux.grid.RowEditor({
            saveText: 'Update',
            buttonAlign:'center',
            RowEditor:true,
            errorSummary:false,
            listeners:{
                'afteredit':function(editor, changes, record){
                    record.set('id', 0);
                    record.commit();
                    editor.grid.getStore().save();
                }
            }
        });
        
        var Record = Ext.data.Record.create(config.fields);

        config = Ext.apply({
            layout:'fit',
            frame: false,
            autoScroll:true,
            closable: true,
            region:'center',
            loadMask:true,
            plugins:[editor],
            tbar:{
                items:[{
                    text: 'Add',
                    iconCls: 'icon-add',
                    handler: function(button) {
                        var grid = button.findParentByType('editabletabledatagrid');
                        var u = new Record();
                        editor.stopEditing();
                        grid.store.insert(0, u);
                        grid.getView().refresh();
                        grid.getSelectionModel().selectRow(0);
                        editor.startEditing(0);
                    }
                },
                '-',
                {
                    text: 'Delete',
                    iconCls: 'icon-delete',
                    handler: function(button) {
                        var grid = button.findParentByType('editabletabledatagrid');
                        var rec = grid.getSelectionModel().getSelected();
                        if (!rec) {
                            return false;
                        }
                        grid.store.remove(rec);
                    }
                }]
            }
        }, config);
        Compass.RailsDbAdmin.EditableTableDataGrid.superclass.constructor.call(this, config);
    }
});

Ext.reg('editabletabledatagrid', Compass.RailsDbAdmin.EditableTableDataGrid);





