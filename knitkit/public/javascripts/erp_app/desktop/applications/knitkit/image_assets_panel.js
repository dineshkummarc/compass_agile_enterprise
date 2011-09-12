Compass.ErpApp.Desktop.Applications.Knitkit.ImageAssetsPanel = function() {
    var self = this;
    this.websiteId = null;
	this.imageAssetsDataView = Ext.create("Ext.view.View",{
        id:'images',
        autoDestroy:true,
        style:'overflow:auto',
        store: Ext.create('Ext.data.Store', {
            proxy: {
                type: 'ajax',
                url: '/knitkit/erp_app/desktop/image_assets/get_images',
                reader: {
                    type: 'json',
                    root: 'images'
                }
            },
            fields:['name', 'url','shortName']
        }),
        tpl: new Ext.XTemplate(
            '<tpl for=".">',
            '<div class="thumb-wrap" id="{name}">',
            '<div class="thumb"><img src="{url}" class="thumb-img"></div>',
            '<span>{shortName}</span></div>',
            '</tpl>')
    });

    this.fileTreePanel = Ext.create("Compass.ErpApp.Shared.FileManagerTree",{
        //TODO_EXTJS4 this is added to fix error should be removed when extjs 4 releases fix.
        viewConfig:{
            loadMask: false
        },
		rootText:'Images',
        autoDestroy:true,
        allowDownload:false,
        addViewContentsToContextMenu:false,
        rootVisible:true,
        controllerPath:'/knitkit/erp_app/desktop/image_assets',
        standardUploadUrl:'/knitkit/erp_app/desktop/image_assets/upload_file',
        xhrUploadUrl:'/knitkit/erp_app/desktop/image_assets/upload_file',
        url:'/knitkit/erp_app/desktop/image_assets/expand_directory',
        containerScroll: true,
        height:200,
        title:'Images',
        collapsible:true,
        region:'north',
        listeners:{
            'itemclick':function(view, record, item, index, e){
                if(self.websiteId != null){
					e.stopEvent();
	                if(!record.data["leaf"])
	                {
	                    var store = self.imageAssetsDataView.getStore();
	                    store.setProxy({
	                        type: 'ajax',
	                        url: '/knitkit/erp_app/desktop/image_assets/get_images',
	                        reader: {
	                            type: 'json',
	                            root: 'images'
	                        },
	                        extraParams:{
	                            directory:record.data.id,
								website_id:self.websiteId
	                        }
	                    });
	                    store.load();
	                }
	                else{
	                    return false;
	                }
				}
            },
            'fileDeleted':function(fileTreePanel, node){
                var store = self.imageAssetsDataView.getStore();
                store.load();
            },
            'fileUploaded':function(fileTreePanel, node){
                var store = self.imageAssetsDataView.getStore();
                store.load();
            }
        }
    });

    var imagesPanel = new Ext.Panel({
        id:'image-assets',
        autoDestroy:true,
        title:'Available Images',
        region:'center',
        margins: '5 5 5 0',
        layout:'fit',
        items: this.imageAssetsDataView
    });

    this.layout = new Ext.Panel({
        layout: 'border',
        autoDestroy:true,
        title:'Image Assets',
        items: [this.fileTreePanel, imagesPanel]
    });

	this.selectWebsite = function(websiteId){
		this.websiteId = websiteId;
		this.fileTreePanel.extraPostData = {website_id:websiteId};
		this.fileTreePanel.getStore().setProxy({
			type: 'ajax',
            url:'/knitkit/erp_app/desktop/image_assets/expand_directory',
			extraParams:{
				website_id:websiteId
			}
		});
		this.fileTreePanel.getStore().load();
		var store = this.imageAssetsDataView.getStore().removeAll();
	}
}



