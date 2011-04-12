Compass.ErpApp.Desktop.Applications.Knitkit.FileAssetsPanel = function(module) {
    var self = this;
    self.module = module;
	
    this.fileTreePanel = new Compass.ErpApp.Shared.FileManagerTree({
        autoDestroy:true,
        allowDownload:false,
        addViewContentsToContextMenu:false,
        rootVisible:true,
        controllerPath:'./knitkit/file_assets',
        standardUploadUrl:'./knitkit/file_assets/upload_file',
        xhrUploadUrl:'./knitkit/file_assets/upload_file',
        loader: new Ext.tree.TreeLoader({
            dataUrl:'./knitkit/file_assets/expand_directory'
        }),
        containerScroll: true,
        additionalContextMenuItems:[
        {
            nodeType:'leaf',
            text:'Insert link at cursor',
            iconCls:'icon-add',
            listeners:{
                scope:self,
                'click':function(){
                    var node = this.fileTreePanel.selectedNode;
                    Ext.MessageBox.prompt('Display Name', 'Please enter display name:', function(btn, text){
                        if(btn == 'ok'){
                            self.module.centerRegion.insertHtmlIntoActiveCkEditor('<a href="#" onclick="window.open(\'/erp_app/public/download_file/?path='+node.id+'\',\'mywindow\',\'width=400,height=200\');return false;">'+text+'</a>');
                        }
                    });
                }
            }
        }
        ],
        height:200,
        title:'Files',
        listeners:{
            'click':function(node){
            },
            'fileDeleted':function(fileTreePanel, node){
            },
            'fileUploaded':function(fileTreePanel, node){
                
            }
        }
    });
    
    this.layout = new Ext.Panel({
        layout: 'fit',
        autoDestroy:true,
        title:'File Assets',
        items: [this.fileTreePanel],
        listeners:{
            'activate':function(){
                self.fileTreePanel.getRootNode().reload();
            }
        }
    });
}

