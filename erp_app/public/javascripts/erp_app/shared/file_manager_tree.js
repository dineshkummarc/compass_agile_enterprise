Ext.define("Compass.ErpApp.Shared.FileManagerTree",{
    extend:"Ext.tree.Panel",
    alias:'widget.compassshared_filemanager',
	extraPostData:{},
    /*
	addtional config options
	
	additionalContextMenuItems : any additional context menus you want to add
	allowDownload		   : if the user can download the file


        window.file_manager_context_menu_node
        the above variable will be set when the context menu is shown.
     */

    initComponent: function() {
        this.callParent(arguments);
        this.addEvents(
            /**
         * @event fileDeleted
         * Fired after file is deleted.
         * @param {Compass.ErpApp.Shared.FileManagerTree} fileManagerTree This object
         * @param {Ext.data.model} model that represents tree node
         */
            'fileDeleted',
            /**
         * @event fileuploaded
         * Fired after file is uploaded.
         * @param {Compass.ErpApp.Shared.FileManagerTree} fileManagerTree This object
         * @param {Ext.data.model} model that represents tree node
         */
            'fileUploaded',
            /**
         * @event contentLoaded
         * Fired after cotent is loaded from server
         * @param {Compass.ErpApp.Shared.FileManagerTree} fileManagerTree This object
	 * @param {Ext.data.Model} model that represents tree node
         * @param (String) content returned from server
         */
            'contentLoaded',
            /**
         * @event contextMenu
         * Fired after content is loaded from server
         * @param {Compass.ErpApp.Shared.FileManagerTree} fileManagerTree This object
         * @param {Ext.data.model} model that represents tree node
         * @param (Event) event for this click
         */
            'handleContextMenu',
            /**
         * @event beforedrop_view
         * call through for beforedrop view event.
         */
            'beforedrop_view',
            /**
         * @event drop_view
         * call through for drop view event.
         */
            'drop_view'
            );
    },

    selectedNode:null,

    constructor: function(config){
        var self = this;
        
        var store = Ext.create('Ext.data.TreeStore', {
            proxy: {
                type: 'ajax',
                url:config['url'] || './file_manager/base/expand_directory'
            },
            root: {
                text: 'Files',
                id:'root_node',
                expanded: true
            },
            fields:config['fields'] || [{name:'text'},{name:'downloadPath'},{name:'id'},{name:'leaf'}]
        });

        var defaultListeners = {
            scope:this,
            'itemmove':function(node, oldParent, newParent, index, options){
                Ext.MessageBox.confirm('Confirm', 'Are you sure you want to move this file?', function(btn){
                    if(btn == 'no'){
                        store.load({node:oldParent});
                        store.load({node:newParent});
                        return false;
                    }
                    else
                    if(btn == 'yes')
                    {
                        var msg = Ext.Msg.wait("Saving", "Saving move...");
                        var conn = new Ext.data.Connection();
                        Ext.apply(self.extraPostData, {node:node.data.id, parent_node:newParent.data.id});
						conn.request({
							url: (self.initialConfig['controllerPath'] || './file_manager/base') + '/save_move',
                            method: 'POST',
                            params:self.extraPostData,
                            success: function(response) {
                                msg.hide();
								var responseObj = Ext.decode(response.responseText);
                                Ext.Msg.alert('Status', responseObj.msg);
								store.load({node:newParent});
                            },
                            failure: function(response) {
                                msg.hide();
								var responseObj = Ext.decode(response.responseText);
                                Ext.Msg.alert('Status', responseObj.msg);
                            }
                        });
                    }
                });
            },
            'itemclick':function(view, record, item, index, e){
                e.stopEvent();
                if(record.get('leaf')){
                    var msg = Ext.Msg.wait("Loading", "Retrieving contents...");
                    var conn = new Ext.data.Connection();
                    conn.request({
                        url: (self.initialConfig['controllerPath'] || './file_manager/base') + '/get_contents',
                        method: 'POST',
                        params:{
                            node:record.data.id
                        },
                        success: function(response) {
                            msg.hide();
                            self.fireEvent('contentLoaded', this, record, response.responseText);
                        },
                        failure: function() {
                            Ext.Msg.alert('Status', 'Error loading contents');
                            msg.hide();
                        }
                    });
                }
            },
            'itemcontextmenu':function(view, record, item, index, e){
                e.stopEvent();
                if(record.data['contextMenuDisabled']) return false;
                if(record.data['handleContextMenu']){
                    self.fireEvent('handleContextMenu', this, record, e);
                    return false;
                }

                self.selectedNode = record;
                var menuItems = [
                {
                    text:'Rename',
                    iconCls:'icon-edit',
                    listeners:{
                        'click':function(){
                            var renameForm = {
                                xtype:'form',
                                autoDestroy:true,
                                width: 500,
                                frame: true,
                                buttonAlign:'center',
                                bodyStyle: 'padding: 10px 10px 0 10px;',
                                labelWidth: 50,
                                defaults: {
                                    anchor: '95%',
                                    allowBlank: false,
                                    msgTarget: 'side',
                                    labelWidth:50
                                },
                                items: [{
                                    xtype: 'textfield',
                                    fieldLabel: 'Name',
                                    name:'file_name',
                                    value:record.data["text"]
                                },{
                                    xtype:'hidden',
                                    name:'node',
                                    value:record.data.id
                                }],
                                buttons: [{
                                    text: 'Save',
                                    handler: function(btn){
                                        var renameForm = btn.findParentByType('form');
                                        if(renameForm.getForm().isValid()){
                                            Ext.apply(self.extraPostData, renameForm.getValues());
											var msg = Ext.Msg.wait("Loading", "Renaming file...");
		                                    var conn = new Ext.data.Connection();
		                                    conn.request({
		                                        url: (self.initialConfig['controllerPath'] || './file_manager/base') + '/rename_file',
		                                        method: 'POST',
		                                        params:self.extraPostData,
		                                        success: function(response) {
		                                          msg.close();
												  var responseObj =  Ext.decode(response.responseText);
	                                              if(responseObj.success){
                                                       store.load({
                                                           node:record.parentNode
                                                       });
                                                       var window = renameForm.findParentByType('window');
                                                       window.close()
                                                   }
                                                   else{
                                                       Ext.Msg.alert("Error", responseObj.error);
                                                   }
		                                        },
		                                        failure: function(response) {
		                                          msg.close();
												  var responseObj =  Ext.decode(response.responseText);
			                                      msg.hide();
			                                      Ext.Msg.alert('Status', responseObj.msg);
		                                        }
		                                    });
                                        }
                                    }
                                },{
                                    text: 'Reset',
                                    handler: function(btn){
                                        var renameForm = btn.findParentByType('form');
                                        renameForm.getForm().reset();
                                    }
                                }]
                            };

                            var type = '';
                            if(record.data["leaf"]){
                                type = 'file'
                            }
                            else{
                                type = 'directory'
                            }

                            var renameWindow = Ext.create('Ext.window.Window', {
                                title:'Rename ' + type,
                                layout: 'fit',
                                width:500,
                                height:120,
                                items:[
                                renameForm
                                ]
                            });

                            renameWindow.show();
                        }
                    }
                },
                {
                    text:'Delete',
                    iconCls:'icon-delete',
                    listeners:{
                        scope:this,
                        'click':function(){
                            Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this file?', function(btn){
                                if(btn == 'no'){
                                    return false;
                                }
                                else
                                if(btn == 'yes')
                                {
                                    Ext.apply(self.extraPostData, {node:record.data.id});
									var msg = Ext.Msg.wait("Loading", "Deleting file...");
                                    var conn = new Ext.data.Connection();
                                    conn.request({
                                        url: (self.initialConfig['controllerPath'] || './file_manager/base') + '/delete_file',
                                        method: 'POST',
                                        params:self.extraPostData,
                                        success: function(response) {
                                            var responseObj =  Ext.decode(response.responseText);
                                            msg.hide();
                                            if(responseObj.success){
                                                record.remove(true);
                                                self.fireEvent('fileDeleted', this, record);
                                            }
                                            else{
                                                Ext.Msg.alert("Error", responseObj.error);
                                            }
                                        },
                                        failure: function(response) {
                                            var responseObj =  Ext.decode(response.responseText);
                                            msg.hide();
                                            Ext.Msg.alert('Status', responseObj.msg);
                                        }
                                    });
                                }
                            });
                        }
                    }
                }
                ];
				
                //add additional menu items if they are passed in the config
                //check to see where the should show, folders, leafs, or all
                if(!Compass.ErpApp.Utility.isBlank(this.initialConfig['additionalContextMenuItems']))
                {
                    Ext.each(this.initialConfig['additionalContextMenuItems'], function(item){
                        if(item.nodeType == 'folder' && !record.data['leaf']){
                            menuItems.push(item);
                        }
                        else if(item.nodeType == 'leaf' && record.data['leaf']){
                            menuItems.push(item);
                        }
                        else if(Compass.ErpApp.Utility.isBlank(item.nodeType)){
                            menuItems.push(item);
                        }
                    });
                }
				
                //if this is not a leaf allow reload
                if(!record.data['leaf']){
                    /*reload folder menu item*/
                    menuItems.push({
                        text:'Reload',
                        iconCls:'icon-recycle',
                        listeners:{
                            scope:this,
                            'click':function(){
                                store.load({
                                    node:record
                                });
                            }
                        }
                    });

                    /*upload menu item*/
                    menuItems.push({
                        text:'Upload',
                        iconCls:'icon-upload',
                        listeners:{
                            scope:self,
                            'click':function(){
                                Ext.apply(self.extraPostData, {directory:record.data.id});
								var uploadWindow = new Compass.ErpApp.Shared.UploadWindow({
                                    standardUploadUrl:this.initialConfig['standardUploadUrl'],
                                    flashUploadUrl:this.initialConfig['flashUploadUrl'],
                                    xhrUploadUrl:this.initialConfig['xhrUploadUrl'],
                                    extraPostData:self.extraPostData,
                                    listeners:{
                                        'fileuploaded':function(){
                                            store.load({
                                                node:record
                                            });
                                            self.fireEvent('fileUploaded', this, record);
                                        }
                                    }
                                });
                                uploadWindow.show();
                            }
                        }
                    });

                    /*new file*/
                    menuItems.push({
                        text:'New File',
                        iconCls:'icon-document',
                        listeners:{
                            scope:self,
                            'click':function(){
                                Ext.MessageBox.prompt('New File', 'Please enter new file name:', function(btn, text){
                                    if(btn == 'ok'){
                                        Ext.apply(self.extraPostData, {path:record.data.id,name:text});
										var msg = Ext.Msg.wait("Processing", "Creating new file...");
                                        var conn = new Ext.data.Connection();
                                        conn.request({
                                            url: (self.initialConfig['controllerPath'] || './file_manager/base') + '/create_file',
                                            method: 'POST',
                                            params:self.extraPostData,
                                            success: function(response) {
                                                msg.hide();
                                                store.load({
                                                    node:record
                                                });
                                            },
                                            failure: function() {
                                                Ext.Msg.alert('Status', 'Error creating file.');
                                                msg.hide();
                                            }
                                        });
                                    }
                                });
                            }
                        }
                    });

                    /*new folder menu item*/
                    menuItems.push({
                        text:'New Folder',
                        iconCls:'icon-content',
                        listeners:{
                            scope:this,
                            'click':function(){
                                Ext.MessageBox.prompt('New Folder', 'Please enter new folder name:', function(btn, text){
                                    if(btn == 'ok'){
                                        Ext.apply(self.extraPostData, {path:record.data.id,name:text});
										var msg = Ext.Msg.wait("Processing", "Creating new folder...");
                                        var conn = new Ext.data.Connection();
                                        conn.request({
                                            url: (self.initialConfig['controllerPath'] || './file_manager/base') + '/create_folder',
                                            method: 'POST',
                                            params:self.extraPostData,
                                            success: function(response) {
                                                msg.hide();
                                                store.load({
                                                    node:record
                                                });
                                            },
                                            failure: function() {
                                                Ext.Msg.alert('Status', 'Error creating folder.');
                                                msg.hide();
                                            }
                                        });
                                    }
                                });
                            }
                        }
                    });
                }
                else{
                    //check if we are allowing to view contents
                    if(this.initialConfig['addViewContentsToContextMenu']){
                        menuItems.push({
                            text:'View Contents',
                            iconCls:'icon-document',
                            listeners:{
                                'click':function(){
                                    var msg = Ext.Msg.wait("Loading", "Retrieving contents...");
                                    var conn = new Ext.data.Connection();
                                    conn.request({
                                        url: (self.initialConfig['controllerPath'] || './file_manager/base') + '/get_contents',
                                        method: 'POST',
                                        params:{
                                            node:record.data.id
                                        },
                                        success: function(response) {
                                            msg.hide();
                                            self.fireEvent('contentLoaded', this, record, response.responseText);
                                        },
                                        failure: function() {
                                            Ext.Msg.alert('Status', 'Error loading contents');
                                            msg.hide();
                                        }
                                    });
                                }
                            }
                        });
                    }
					
                    if(this.initialConfig['allowDownload']){
                        menuItems.push({
                            text:'Download File',
                            iconCls:'icon-document',
                            listeners:{
                                'click':function(){
                                    window.open("./file_manager/base/download_file/?path=" + record.data.id,'mywindow','width=400,height=200');
                                }
                            }
                        });
                    }
                }

                var contextMenu = new Ext.menu.Menu({
                    items:menuItems
                });
                window.file_manager_context_menu_node = record;
                contextMenu.showAt(e.xy);
            }
        };
	
        var i;
        for(i in config.listeners)
            defaultListeners[i] = config.listeners[i];
		
        config['listeners'] = defaultListeners;

        config = Ext.apply({
            store:store,
            animate:false,
            containerScroll: true,
            autoDestroy:true,
            split:true,
            autoScroll:true,
            margins: '5 0 5 5',
            viewConfig: {
                //TODO_EXTJS4 this is added to fix error should be removed when extjs 4 releases fix.
                loadMask: false,
                plugins: {
                    ptype: 'treeviewdragdrop'
                },
                listeners:{
                    'beforedrop':function(node, data, overModel, dropPosition,dropFunction,options){
                        self.fireEvent('beforedrop_view', node, data, overModel, dropPosition,dropFunction,options);
                    },
                    'drop':function(node, data, overModel, dropPosition, options){
                        self.fireEvent('drop_view', node, data, overModel, dropPosition, options);
                    }
                }
            }
        }, config);
		
        this.callParent([config]);
    }
});
