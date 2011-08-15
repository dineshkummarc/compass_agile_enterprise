Compass.ErpApp.Desktop.Applications.Knitkit.FileAssetsPanel = function(module) {
    var self = this;
    self.module = module;
	
    this.fileTreePanel = Ext.create("Compass.ErpApp.Shared.FileManagerTree",{
        autoDestroy:true,
        allowDownload:false,
        addViewContentsToContextMenu:false,
        rootVisible:true,
        controllerPath:'/knitkit/erp_app/desktop/file_assets',
        standardUploadUrl:'/knitkit/erp_app/desktop/file_assets/upload_file',
        xhrUploadUrl:'/knitkit/erp_app/desktop/file_assets/upload_file',
        url:'/knitkit/erp_app/desktop/file_assets/expand_directory',
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
            'itemclick':function(view, record, item, index, e){
                e.stopEvent();
                return false;
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
        items: [this.fileTreePanel]
    });
}

