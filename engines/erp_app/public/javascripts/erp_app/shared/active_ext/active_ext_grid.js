Ext.ns("Compass.ErpApp.Shared.ActiveExt");

Compass.ErpApp.Shared.ActiveExt.ActiveExtGrid = Ext.extend(Ext.grid.GridPanel, {
    initComponent: function() {
        var config = this.initialConfig
        var messageBox = null;

        var proxy = new Ext.data.HttpProxy({
            url: config['url']
        });

        proxy.addListener('exception', function(proxy, type, action, options, res) {
            var message = 'Error in processing request';
            if(!Compass.ErpApp.Utility.isBlank(res.message)) message = res.message;
            Ext.Msg.alert('Error', message);
        });

        proxy.addListener('beforewrite', function(proxy, action) {
            if(messageBox != null)
                messageBox.hide();

            messageBox = Ext.Msg.wait('Status', 'Sending request...');
        });

        proxy.addListener('write', function(dataProxy, action, data, response, rs, options) {
            if(messageBox != null)
                messageBox.hide();

            if(!Compass.ErpApp.Utility.isBlank(response.message)){
                var message = response.message;
                Ext.Msg.alert('Status', message);
            }
        });

        var reader = new Ext.data.JsonReader({
            successProperty: 'success',
            totalProperty:'totalCount',
            idProperty: 'id',
            root: 'data',
            messageProperty: 'message'
        },this.initialConfig['fields']);

        var writer = new Ext.data.JsonWriter({
            encode: false
        });

        var store = new Ext.data.Store({
            autoLoad:true,
            restful: true,
            proxy: proxy,
            reader: reader,
            baseParams:{
                limit:config['pageSize']
            },
            writer: writer,
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

        if(config['page'] == true){
            this.bbar = new Ext.PagingToolbar({
                pageSize: config['pageSize'],
                store: store,
                displayInfo: true,
                displayMsg: config['displayMsg'],
                emptyMsg: config['emptyMsg']
            });
        }

        Compass.ErpApp.Shared.ActiveExt.ActiveExtGrid.superclass.initComponent.apply(this, arguments);
    },

    constructor : function(config) {
        var editor = new Ext.ux.grid.RowEditor({
            saveText: 'Update',
            buttonAlign:'center',
            RowEditor:true,
            errorSummary:true,
            listeners:{
                'afteredit':function(editor, changes, record){
                    if(Compass.ErpApp.Utility.isBlank(record.get('id'))){
                        record.set('id', 0);
                    }
                    else{
                        record.commit();
                    }
                }
            }
        });

        var Record = Ext.data.Record.create(config.fields);

        var plugins = [];
        var tbar = {};
        if(config['editable']){
            if(config['inline_edit']){
                plugins.push(editor);
                tbar = {
                    items:[{
                        text: 'Add',
                        iconCls: 'icon-add',
                        handler: function(button) {
                            var grid = button.findParentByType('activeextgrid');
                            var r = new Record();
                            editor.stopEditing();
                            grid.store.insert(0, r);
                            editor.startEditing(0);
                        }
                    },
                    '-',
                    {
                        text: 'Delete',
                        iconCls: 'icon-delete',
                        handler: function(button) {
                            var grid = button.findParentByType('activeextgrid');
                            var rec = grid.getSelectionModel().getSelected();
                            if (!rec) {
                                return false;
                            }
                            grid.store.remove(rec);
                        }
                    }]
                };
            }
            else{
                var windowTitle = config['windowTitle'];
                var modelUrl = config['modelUrl'];
                config['columns'].unshift({
                    xtype:'actioncolumn',
                    header:'Edit',
                    width:30,
                    items:[{
                        icon:'/images/icons/edit/edit_16x16.png',
                        tooltip:'Edit',
                        handler :function(grid, rowIndex, colIndex){
                            var rec = grid.getStore().getAt(rowIndex);
                            var modeId = rec.get('id');
                            var win = new Ext.Window({
                                width:500,
                                height:500,
                                border:false,
                                layout:'fit',
                                title:'Edit - ' + windowTitle,
                                items:[{xtype:'panel', frame:false, html:"<iframe height='100%' width='100%' src='"+modelUrl+"/edit/"+modeId+"'></iframe>"}]
                            });
                            win.show();
                        }
                    }]
                });
            }
        }
        
        config = Ext.apply({
            layout:'fit',
            frame: false,
            autoScroll:true,
            loadMask:true,
            plugins:plugins,
            tbar:tbar
        }, config);
        Compass.ErpApp.Shared.ActiveExt.ActiveExtGrid.superclass.constructor.call(this, config);
    }
});

Ext.reg('activeextgrid', Compass.ErpApp.Shared.ActiveExt.ActiveExtGrid);