Ext.define("Compass.ErpApp.Shared.ActiveExt.ActiveExtGrid",{
    extend:"Ext.grid.GridPanel",
    alias:'widget.activeextgrid',
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
        var formAction = null;

        switch(action){
            case 'new':
                formAction = 'create';
                break;
            case 'edit':
                formAction = 'update';
                break;
        }

        Ext.Ajax.request({
            url: this.initialConfig.modelUrl + '/' + action,
            method: 'POST',
            params:{
                id:id
            },
            success: function(response) {
                self.clearWindowStatus();
                var formItems =  Ext.decode(response.responseText);
                var buttons = [];
                if(action != 'show'){
                    buttons = [{
                        text:'Submit',
                        listeners:{
                            'click':function(button){
                                var window = button.findParentByType('window');
                                var formPanel = window.query('.form')[0];
                                self.setWindowStatus('Working');
                                formPanel.getForm().submit({
                                    reset:true,
                                    success:function(form, action){
                                        self.clearWindowStatus();
                                        var obj = Ext.decode(action.response.responseText);
                                        if(obj.success){
                                            activeExtFormWindow.close();
                                            self.store.load();
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
                    width:320,
                    title:self.initialConfig.windowTitle,
                    height:300,
                    plain: true,
                    autoScroll:true,
                    buttonAlign:'center',
                    items: Ext.create('Ext.form.Panel',{
                        frame:false,
                        fieldDefaults: {
                            width: 225,
                            labelWidth: 100
                        },
                        bodyStyle:'padding:5px 5px 0',
                        url:self.initialConfig.modelUrl + '/' + formAction,
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
        var config = this.initialConfig;
        var store = Ext.create('Ext.data.Store', {
            fields:config['fields'],
            autoLoad: true,
            autoSync: true,
            proxy: {
                type: 'rest',
                url:config.modelUrl + '/data',
                reader: {
                    type: 'json',
                    successProperty: 'success',
                    root: 'data',
                    messageProperty: 'message'
                },
                writer: {
                    type: 'json',
                    writeAllFields:true,
                    root: 'data'
                },
                listeners: {
                    exception: function(proxy, response, operation){
                        Ext.MessageBox.show({
                            title: 'REMOTE EXCEPTION',
                            msg: operation.getError(),
                            icon: Ext.MessageBox.ERROR,
                            buttons: Ext.Msg.OK
                        });
                    }
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

        this.callParent(arguments);
    },

    constructor : function(config) {
        var self = this;

        this.editing = Ext.create('Ext.grid.plugin.RowEditing', {
            clicksToMoveEditor: 1
        });

        var Model = Ext.define(config.windowTitle,{
            extend:'Ext.data.Model',
            fields:config.fields,
            validations:config.validations
        });
        
        var plugins = [];
        var tbar = {};
        if(config.editable){
            if(config.inlineEdit){
                plugins.push(this.editing);
                tbar = {
                    items:[{
                        text: 'Add',
                        iconCls: 'icon-add',
                        handler: function(button) {
                            var grid = button.findParentByType('activeextgrid');
                            var edit = grid.editing;
                            grid.store.insert(0, new Model());
                            edit.startEdit(0,0);
                        }
                    },'-',
                    {
                        text:'Delete',
                        iconCls: 'icon-delete',
                        handler: function(button){
                            var grid = button.findParentByType('activeextgrid');
                            var selection = grid.getView().getSelectionModel().getSelection()[0];
                            if (selection) {
                                grid.store.remove(selection);
                            }
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
            id:config.windowTitle+'_',
            autoScroll:true,
            loadMask:true,
            plugins:plugins,
            tbar:tbar
        }, config);
        
		this.callParent([config]);
    }
});

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