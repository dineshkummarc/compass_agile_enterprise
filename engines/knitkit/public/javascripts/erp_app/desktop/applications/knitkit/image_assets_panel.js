Compass.ErpApp.Desktop.Applications.Knitkit.ImageAssetsPanel = function() {
    var self = this;
    this.imageAssetsDataView = new Ext.DataView({
        id:'images',
        autoDestroy:true,
        itemSelector: 'div.thumb-wrap',
        style:'overflow:auto',
        multiSelect: true,
        plugins: new Ext.DataView.DragSelector({
            dragSafe:true
        }),
        store: new Ext.data.JsonStore({
            url: './knitkit/image_assets/get_images',
            autoLoad: false,
            baseParams:{
                directory:null
            },
            root: 'images',
            id:'name',
            fields:['name', 'url','shortName']
        }),
        tpl: new Ext.XTemplate(
            '<tpl for=".">',
            '<div class="thumb-wrap" id="{name}">',
            '<div class="thumb"><img src="{url}" class="thumb-img"></div>',
            '<span>{shortName}</span></div>',
            '</tpl>'
            )
    });

    this.fileTreePanel = new Compass.ErpApp.Shared.FileManagerTree({
        autoDestroy:true,
        xtype:'compassshared_filemanager',
        collapsible:true,
        allowDownload:false,
        standardUploadUrl:'./knitkit/image_assets/upload_file',
        xhrUploadUrl:'./knitkit/image_assets/upload_file',
        addViewContentsToContextMenu:false,
        rootVisible:true,
        loader: new Ext.tree.TreeLoader({
            dataUrl:'./knitkit/image_assets/expand_directory'
        }),
        containerScroll: true,
        controllerPath:'./knitkit/image_assets',
        region:'north',
        height:200,
        title:'Images',
        listeners:{
            'click':function(node){
                if(!node.attributes["leaf"])
                {
                    var store = self.imageAssetsDataView.getStore();
                    store.setBaseParam('directory', node.id);
                    store.reload();
                }
            },
            'fileDeleted':function(fileTreePanel, node){
                var store = self.imageAssetsDataView.getStore();
                store.reload();
            },
            'fileUploaded':function(fileTreePanel, node){
                var store = self.imageAssetsDataView.getStore();
                store.reload();
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
        items: [this.fileTreePanel, imagesPanel],
        listeners:{
            'activate':function(){
                self.fileTreePanel.getRootNode().reload();
            }
        }
    });
}



