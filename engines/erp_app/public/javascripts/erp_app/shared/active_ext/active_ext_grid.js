Ext.ns("Compass.ErpApp.Shared.ActiveExt");

Compass.ErpApp.Shared.ActiveExt.ActiveExtGrid = Ext.extend(Ext.grid.GridPanel, {
    setWindowStatus : function(status){
        this.findParentByType('statuswindow').setStatus(status);
    },
    
    clearWindowStatus : function(){
        this.findParentByType('statuswindow').clearStatus();
    },

    evalColumnRenderer : function(column){
        if(!Compass.ErpApp.Utility.isBlank(column['renderer'])){
            column['renderer'] = eval(column['renderer']);
        }
    },

    loadForm : function(id, action){
        var self = this;
        this.setWindowStatus('Loading form...');
        var conn = new Ext.data.Connection();
        var formAction = null;

        switch(action){
            case 'new':
                formAction = 'create';
                break;
            case 'edit':
                formAction = 'update';
                break;
        }

        conn.request({
            url: this.initialConfig.modelUrl + '/' + action,
            method: 'POST',
            params:{
                id:id
            },
            success: function(response) {
                self.clearWindowStatus();
                var formItems =  Ext.util.JSON.decode(response.responseText);
                var buttons = [];
                if(action != 'show'){
                    buttons = [{
                        text:'Submit',
                        listeners:{
                            'click':function(button){
                                var window = button.findParentByType('window');
                                var formPanel = window.findByType('form')[0];
                                self.setWindowStatus('Working');
                                formPanel.getForm().submit({
                                    reset:true,
                                    success:function(form, action){
                                        self.clearWindowStatus();
                                        var obj =  Ext.util.JSON.decode(action.response.responseText);
                                        if(obj.success){
                                            activeExtFormWindow.close();
                                            self.getStore().reload();
                                        }
                                        else{
                                            Ext.Msg.alert("Error", "Error");
                                        }
                                    },
                                    failure:function(form, action){
                                        self.clearWindowStatus();
                                        Ext.Msg.alert("Error", "Error");
                                    }
                                });
                            }
                        }
                    },{
                        text: 'Close',
                        handler: function(){
                            activeExtFormWindow.close();
                        }
                    }];
                }

                var activeExtFormWindow = new Ext.Window({
                    layout:'fit',
                    width:320,
                    title:self.initialConfig.windowTitle,
                    height:300,
                    plain: true,
                    autoScroll:true,
                    buttonAlign:'center',
                    items: new Ext.FormPanel({
                        frame:false,
                        bodyStyle:'padding:5px 5px 0',
                        width: 425,
                        url:self.initialConfig.modelUrl + '/' + formAction,
                        defaults: {
                            width: 225
                        },
                        items:formItems
                    }),
                    buttons: buttons
                });
                activeExtFormWindow.show();
                
            },
            failure: function(response) {
                self.clearWindowStatus();
                Ext.Msg.alert('Error', 'Error loading form');
            }
        });
    },
    
    initComponent : function() {
        var config = this.initialConfig
        var messageBox = null;

        var proxy = new Ext.data.HttpProxy({
            url: this.initialConfig.modelUrl + '/data'
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
        var self = this;
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
        if(config.editable){
           
            if(config.inlineEdit){
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
                    },'-',
                    {
                        text:'Delete',
                        iconCls: 'icon-delete',
                        handler: function(button){
                            var grid = button.findParentByType('activeextgrid');
                            var rec = grid.getSelectionModel().getSelected();
                            if (!rec) {
                                return false;
                            }
                            grid.store.remove(rec);
                        }
                    }
                    ]
                };
            }
            else{
                var windowTitle = config['windowTitle'];
                var modelUrl = config['modelUrl'];

                tbar = {
                    items:[
                    {
                        text: 'Add',
                        iconCls: 'icon-add',
                        handler: function(button) {
                            if(self.initialConfig.useExtForms){
                                self.loadForm(null, 'new');
                            }
                            else
                            {
                                var modeId = -1;
                                var win = new Ext.Window({
                                    id: windowTitle.downcase() + "_",
                                    width: 500,
                                    height: 500,
                                    border: false,
                                    layout: 'fit',
                                    title: 'Add - ' + windowTitle,
                                    items: [{
                                        xtype: 'panel',
                                        frame: false,
                                        html: "<iframe height='100%' width='100%' src='" + modelUrl + "/new/" + modeId + "' scrolling='yes'></iframe>"
                                    }]
                                });
                                win.show();
                            }

                        }
                    }
                    ]
                }

                config['columns'].unshift({
                    xtype: 'actioncolumn',
                    width: 30,
                    items: [{
                        icon: '/images/icons/delete/delete_16x16.png',
                        tooltip: 'Delete',
                        handler: function(grid, rowIndex, colIndex){
                            Ext.MessageBox.confirm('Confirm Delete?', 'Are you sure that you want to delete this record?', function(btn){
                                if (btn == 'yes') {
                                    var rec = grid.getStore().getAt(rowIndex);
                                    grid.store.remove(rec);
                                    Ext.MessageBox.alert("Delete Record","Record deleted.");
                                }
                            });
                        }
                    }]
                });

                config['columns'].unshift({
                    xtype:'actioncolumn',
                    width:30,
                    items:[{
                        icon:'/images/icons/edit/edit_16x16.png',
                        tooltip:'Edit',
                        handler :function(grid, rowIndex, colIndex){
                            var rec = grid.getStore().getAt(rowIndex);
                            var id = rec.get('id');
                            if(self.initialConfig.useExtForms){
                                self.loadForm(id, 'edit');
                            }
                            else{
                                var win = new Ext.Window({
                                    id: windowTitle.downcase().underscore() + "_" + id,
                                    width:500,
                                    height:500,
                                    border:false,
                                    layout:'fit',
                                    title:'Edit - ' + windowTitle,
                                    items:[{
                                        xtype:'panel',
                                        frame:false,
                                        html:"<iframe height='100%' width='100%' src='"+modelUrl+"/edit/"+id+"'></iframe>"
                                    }]
                                });
                                win.show();
                            }


                            
                            
                        }
                    }]
                });

                config['columns'].unshift({
                    xtype: 'actioncolumn',
                    width: 30,
                    items: [{
                        icon: '/images/icons/view/view_16x16.png',
                        tooltip: 'Show',
                        handler: function(grid, rowIndex, colIndex){
                            var rec = grid.getStore().getAt(rowIndex);
                            var id = rec.get('id');
                            if(self.initialConfig.useExtForms){
                                self.loadForm(id, 'show');
                            }
                            else
                            {
                                var win = new Ext.Window({
                                    id: windowTitle.downcase().underscore() + "_" + id,
                                    width: 500,
                                    height: 500,
                                    border: false,
                                    layout: 'fit',
                                    title: 'Show - ' + windowTitle,
                                    items: [{
                                        xtype: 'panel',
                                        frame: false,
                                        html: "<iframe id='detail_iframe' height='100%' width='100%' src='" + modelUrl + "/show/" + id + "' scrolling='yes'></iframe>"
                                    }]
                                });
                                win.show();
                            }
                        }
                    }]
                });

                
            }
        }

        Ext.each(config['columns'],this.evalColumnRenderer);
        
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

// refresh the active ext grid component
Compass.ErpApp.Shared.ActiveExt.refreshGrid = function(){
    // get a handle to the active_ext_grid component
    var active_ext_grid=Ext.getCmp("active_ext_grid");
    // reload the grid store
    active_ext_grid.store.reload();

}

// close the window identified by the supplied id
Compass.ErpApp.Shared.ActiveExt.closeWindow = function(windowId){
    //lookup the component by id then close it
    var window=Ext.getCmp(windowId)
    if(window!=null){
        window.close();
    }else{
        alert("["+windowId+"] does not exist");
    }
}