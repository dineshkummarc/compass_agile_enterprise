Compass.ErpApp.Desktop.Applications.Knitkit.FileAssetsPanel = function(module) {
	this.websiteId = null;    
	var self = this;
    self.module = module;
	
	var insertDownloadLink = {
        nodeType:'leaf',
        text:'Insert link at cursor',
        iconCls:'icon-add',
        listeners:{
            scope:self,
            'click':function(){
                var node = this.fileTreePanel.selectedNode;
                Ext.MessageBox.prompt('Display Name', 'Please enter display name:', function(btn, text){
                    if(btn == 'ok'){
                        self.module.centerRegion.insertHtmlIntoActiveCkEditor('<a href="#" onclick="window.open(\'/erp_app/public/download_file/?path='+node.data.downloadPath+'\',\'mywindow\',\'width=400,height=200\');return false;">'+text+'</a>');
                    }
                });
            }
        }
    };
		
    this.sharedFileAssetsTreePanel = Ext.create("Compass.ErpApp.Shared.FileManagerTree",{
        //TODO_EXTJS4 this is added to fix error should be removed when extjs 4 releases fix.
        viewConfig:{loadMask: false},
		title:'Shared',
		allowDownload:false,
        addViewContentsToContextMenu:false,
        rootVisible:true,
        controllerPath:'/knitkit/erp_app/desktop/file_assets/shared',
        standardUploadUrl:'/knitkit/erp_app/desktop/file_assets/shared/upload_file',
        xhrUploadUrl:'/knitkit/erp_app/desktop/file_assets/shared/upload_file',
        url:'/knitkit/erp_app/desktop/file_assets/shared/expand_directory',
        containerScroll: true,
        additionalContextMenuItems:[insertDownloadLink],
        listeners:{
            'itemclick':function(view, record, item, index, e){
                e.stopEvent();
                return false;
            },
            'fileDeleted':function(fileTreePanel, node){},
            'fileUploaded':function(fileTreePanel, node){}
        }
    });

	this.websiteFileAssetsTreePanel = Ext.create("Compass.ErpApp.Shared.FileManagerTree",{
        //TODO_EXTJS4 this is added to fix error should be removed when extjs 4 releases fix.
        viewConfig:{loadMask: false},
		title:'Website',
		allowDownload:false,
        addViewContentsToContextMenu:false,
        rootVisible:true,
        controllerPath:'/knitkit/erp_app/desktop/file_assets/website',
        standardUploadUrl:'/knitkit/erp_app/desktop/file_assets/website/upload_file',
        xhrUploadUrl:'/knitkit/erp_app/desktop/file_assets/website/upload_file',
        url:'/knitkit/erp_app/desktop/file_assets/website/expand_directory',
        containerScroll: true,
        additionalContextMenuItems:[insertDownloadLink],
        listeners:{
            'itemclick':function(view, record, item, index, e){
                e.stopEvent();
                return false;
            },
            'fileDeleted':function(fileTreePanel, node){},
            'fileUploaded':function(fileTreePanel, node){}
        }
    });
    
    this.layout = Ext.create('Ext.panel.Panel',{
        layout: 'fit',
        title:'File Assets',
        items: Ext.create('Ext.tab.Panel',{items:[this.sharedFileAssetsTreePanel, this.websiteFileAssetsTreePanel]})
    });

	this.selectWebsite = function(websiteId){
		this.websiteId = websiteId;
		this.websiteFileAssetsTreePanel.extraPostData = {website_id:websiteId};
		this.websiteFileAssetsTreePanel.getStore().setProxy({
			type: 'ajax',
            url:'/knitkit/erp_app/desktop/file_assets/website/expand_directory',
			extraParams:{website_id:websiteId}
		});
		this.websiteFileAssetsTreePanel.getStore().load();
	}
}

