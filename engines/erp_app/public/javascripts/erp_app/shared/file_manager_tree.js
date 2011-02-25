Compass.ErpApp.Shared.FileManagerTree = Ext.extend(Ext.tree.TreePanel, {
    /*
	addtional config options
	
	additionalContextMenuItems : any additional context menus you want to add
	allowDownload		   : if the user can download the file


        window.file_manager_context_menu_node
        the above variable will be set when the context menu is shown.
     */

    initComponent: function() {
        Compass.ErpApp.Shared.FileManagerTree.superclass.initComponent.call(this, arguments);

        this.addEvents(
            /**
         * @event fileDeleted
         * Fired after file is deleted.
         * @param {Compass.ErpApp.Shared.FileManagerTree} fileManagerTree This object
         * @param (Ext.Tree.Node) node Node that was deleted
         */
            'fileDeleted',
            /**
         * @event fileuploaded
         * Fired after file is uploaded.
         * @param {Compass.ErpApp.Shared.FileManagerTree} fileManagerTree This object
         * @param (Ext.Tree.Node) node Node that was file was uploaded to
         */
            'fileUploaded',
            /**
         * @event contentLoaded
         * Fired after cotent is loaded from server
         * @param {Compass.ErpApp.Shared.FileManagerTree} fileManagerTree This object
	 * @param {Ext.Tree.Node} node Node that content was loaded for
         * @param (String) content returned from server
         */
            'contentLoaded',
             /**
         * @event contextMenu
         * Fired after cotent is loaded from server
         * @param {Compass.ErpApp.Shared.FileManagerTree} fileManagerTree This object
         * @param {Ext.Tree.Node} node Node that content was loaded for
         * @param (Event) event for this click
         */
            'handleContextMenu'
            );

        this.setRootNode({
            xtype:'asynctreenode',
            text: 'Folders',
            id:'root_node',
            allowDrag:false,
            allowDrop:false
        });
    },

    selectedNode:null,

    constructor: function(config){
        var self = this;
        var defaultListeners = {
            scope:this,
            'movenode':function(tree, node, oldParent, newParent, index){
                Ext.MessageBox.confirm('Confirm', 'Are you sure you want to move this file?', function(btn){
                    if(btn == 'no'){
                        oldParent.reload();
                        newParent.reload();
                        return false;
                    }
                    else
                    if(btn == 'yes')
                    {
                        var msg = Ext.Msg.wait("Saving", "Saving move...");
                        var conn = new Ext.data.Connection();
                        conn.request({
                            url: './file_manager/base/save_move',
                            method: 'POST',
                            params:{
                                node:node.id,
                                parent_node:newParent.id
                            },
                            success: function(response) {
                                var responseObj =  Ext.util.JSON.decode(response.responseText);
                                msg.hide();
                                newParent.reload();
                            //Ext.Msg.alert('Status', responseObj.msg);

                            },
                            failure: function(response) {
                                var responseObj =  Ext.util.JSON.decode(response.responseText);
                                msg.hide();
                                Ext.Msg.alert('Status', responseObj.msg);
                            }
                        });
                    }
                });
            },
            'contextmenu':function(node, e){
                e.stopEvent();
                if(node.attributes['contextMenuDisabled']) return false;
                if(node.attributes['handleContextMenu']){
                    self.fireEvent('handleContextMenu', this, node, e);
                    return false;
                }
                self.selectedNode = node;
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
                                autoHeight: true,
                                bodyStyle: 'padding: 10px 10px 0 10px;',
                                labelWidth: 50,
                                defaults: {
                                    anchor: '95%',
                                    allowBlank: false,
                                    msgTarget: 'side'
                                },
                                items: [{
                                    xtype: 'textfield',
                                    fieldLabel: 'Name',
                                    name:'file_name',
                                    value:node.attributes["text"]
                                },{
                                    xtype:'hidden',
                                    name:'node',
                                    value:node.id
                                }],
                                buttons: [{
                                    text: 'Save',
                                    handler: function(btn){
                                        var renameForm = btn.findParentByType('form');
                                        if(renameForm.getForm().isValid()){
                                            renameForm.getForm().submit({
                                                url: './file_manager/base/rename_file',
                                                waitMsg: 'Renaming your file to ...',
                                                success: function(form, o){
                                                    //Ext.Msg.alert('Success', o.result.msg);
                                                    node.parentNode.reload();
                                                    var window = renameForm.findParentByType('window');
                                                    window.close();

                                                },
                                                failure:function(form, o){
                                                    Ext.Msg.alert('Error', o.result.msg);
                                                }
                                            });
                                        }
                                    }
                                },{
                                    text: 'Reset',
                                    handler: function(){
                                        renameForm.getForm().reset();
                                    }
                                }]
                            };

                            var type = '';
                            if(node.attributes["leaf"]){
                                type = 'file'
                            }
                            else{
                                type = 'directory'
                            }

                            var renameWindow = new Ext.Window({
                                title:'Rename ' + type,
                                closeAction:'hide',
                                autoDestroy:true,
                                frame:true,
                                width:500,
                                autoHeight: true,
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
                                    var msg = Ext.Msg.wait("Loading", "Deleting file...");
                                    var conn = new Ext.data.Connection();
                                    conn.request({
                                        url: './file_manager/base/delete_file',
                                        method: 'POST',
                                        params:{
                                            node:node.id
                                        },
                                        success: function(response) {
                                            var responseObj =  Ext.util.JSON.decode(response.responseText);
                                            msg.hide();
                                            //Ext.Msg.alert('Status', responseObj.msg);
                                            node.parentNode.reload();
                                            self.fireEvent('fileDeleted', this, node);
                                        },
                                        failure: function(response) {
                                            var responseObj =  Ext.util.JSON.decode(response.responseText);
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
                        if(item.nodeType == 'folder' && !node.attributes['leaf']){
                            menuItems.push(item);
                        }
                        else if(item.nodeType == 'leaf' && node.attributes['leaf']){
                            menuItems.push(item);
                        }
                        else if(Compass.ErpApp.Utility.isBlank(item.nodeType)){
                            menuItems.push(item);
                        }
                    });
                }
				
                //if this is not a leaf allow reload
                if(!node.attributes['leaf']){
                    /*reload folder menu item*/
                    menuItems.push({
                        text:'Reload',
                        iconCls:'icon-recycle',
                        listeners:{
                            scope:this,
                            'click':function(){
                                node.reload();
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
                                var uploadWindow = new Compass.ErpApp.Shared.UploadWindow({
                                    standardUploadUrl:this.initialConfig['standardUploadUrl'],
                                    flashUploadUrl:this.initialConfig['flashUploadUrl'],
                                    xhrUploadUrl:this.initialConfig['xhrUploadUrl'],
                                    extraPostData:{
                                        directory:node.id
                                    },
                                    listeners:{
                                        'fileuploaded':function(){
                                            node.reload();
                                            self.fireEvent('fileUploaded', this, node);
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
                                        var msg = Ext.Msg.wait("Processing", "Creating new file...");
                                        var conn = new Ext.data.Connection();
                                        conn.request({
                                            url: './file_manager/base/create_file',
                                            method: 'POST',
                                            params:{
                                                path:node.id,
                                                name:text
                                            },
                                            success: function(response) {
                                                msg.hide();
                                                node.reload();
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
                                        var msg = Ext.Msg.wait("Processing", "Creating new folder...");
                                        var conn = new Ext.data.Connection();
                                        conn.request({
                                            url: './file_manager/base/create_folder',
                                            method: 'POST',
                                            params:{
                                                path:node.id,
                                                name:text
                                            },
                                            success: function(response) {
                                                msg.hide();
                                                node.reload();
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
                    var elementToRenderContents = this.initialConfig['elementToRenderContents'];
                    if(this.initialConfig['addViewContentsToContextMenu']){
                        menuItems.push({
                            text:'View Contents',
                            iconCls:'icon-document',
                            listeners:{
                                'click':function(){
                                    var msg = Ext.Msg.wait("Loading", "Retrieving contents...");
                                    var conn = new Ext.data.Connection();
                                    conn.request({
                                        url: './file_manager/base/get_contents',
                                        method: 'POST',
                                        params:{
                                            node:node.id
                                        },
                                        success: function(response) {
                                            msg.hide();
                                            self.fireEvent('contentLoaded', this, node, response.responseText);
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
                                    window.open("./file_manager/base/download_file/?path=" + node.id,'mywindow','width=400,height=200');
                                }
                            }
                        });
                    }
                }

                var contextMenu = new Ext.menu.Menu({
                    items:menuItems
                });
                window.file_manager_context_menu_node = node;
                contextMenu.showAt(e.xy);
            }
        };
	
        var i;
        for(i in config.listeners)
            defaultListeners[i] = config.listeners[i];
		
        config['listeners'] = defaultListeners;
        config = Ext.apply({
            // tree
            animate:false,
            enableDD:true,
            containerScroll: true,
            collapsible:true,
            autoDestroy:true,
            split:true,
            loader: config['loader'] || new Ext.tree.TreeLoader({
                dataUrl:'./file_manager/base/expand_directory'
            }),
            autoScroll:true,
            margins: '5 0 5 5'
        }, config);
		
        Compass.ErpApp.Shared.FileManagerTree.superclass.constructor.call(this, config);
    }
});

Ext.reg('compassshared_filemanager', Compass.ErpApp.Shared.FileManagerTree);
