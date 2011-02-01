Compass.ErpApp.Desktop.Applications.Knitkit.EastRegion = Ext.extend(Ext.TabPanel, {
    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.Knitkit.ImageAssetsDataView = new Ext.DataView({
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
                fields:[
                'name', 'url',
                {
                    name: 'shortName',
                    mapping: 'name'
                //  convert: shortName
                }
                ]
            }),
            tpl: new Ext.XTemplate(
                '<tpl for=".">',
                '<div class="thumb-wrap" id="{name}">',
                '<div class="thumb"><img src="{url}" class="thumb-img"></div>',
                '<span>{shortName}</span></div>',
                '</tpl>'
                )
        });

        var images = new Ext.Panel({
            id:'images',
            title:'Available Images',
            region:'center',
            margins: '5 5 5 0',
            layout:'fit',
            items: Compass.ErpApp.Desktop.Applications.Knitkit.ImageAssetsDataView
        });

        var fileTreePanel = new Compass.ErpApp.Shared.FileManagerTree({
            xtype:'compassshared_filemanager',
            allowDownload:false,
            addViewContentsToContextMenu:false,
            rootVisible:false,
            loader: new Ext.tree.TreeLoader({
                dataUrl:'./knitkit/image_assets/expand_directory'
            }),
            containerScroll: true,
            border: false,
            region:'north',
            height:300,
            title:'Images',
            listeners:{
                'click':function(node){
                    if(!node.attributes["leaf"])
                    {
                        var store = Compass.ErpApp.Desktop.Applications.Knitkit.ImageAssetsDataView.getStore();
                        store.setBaseParam('directory', node.id);
                        store.reload();
                    }
                },
                'fileDeleted':function(fileTreePanel, node){
                    var store = Compass.ErpApp.Desktop.Applications.Knitkit.ImageAssetsDataView.getStore();
                    store.reload();
                }
            },
            additionalContextMenuItems:[
            {
                nodeType:'folder',
                text:'Upload',
                iconCls:'icon-upload',
                listeners:{
                    'click':function(){
                        var node = window.file_manager_context_menu_node;
                        var uploadWindow = new Compass.ErpApp.Shared.UploadWindow({
                            standardUploadUrl:'./knitkit/image_assets/upload_file',
                            flashUploadUrl:'./knitkit/image_assets/upload_file',
                            xhrUploadUrl:'./knitkit/image_assets/upload_file',
                            extraPostData:{
                                directory:node.id
                                },
                            listeners:{
                                'fileuploaded':function(){
                                    node.reload();
                                    var store = Compass.ErpApp.Desktop.Applications.Knitkit.ImageAssetsDataView.getStore();
                                    store.reload();
                                }
                            }
                        });
                        uploadWindow.show();
                    }
                }
            }
            ]
        });

        var layout = new Ext.Panel({
            layout: 'border',
            autoDestroy:true,
            title:'Image Assets',
            items: [fileTreePanel, images]
        });

        //        var dragZone = new ImageDragZone(view, {
        //            containerScroll:true,
        //            ddGroup: 'organizerDD'
        //        });

        this.items = [layout];

        Compass.ErpApp.Desktop.Applications.Knitkit.EastRegion.superclass.initComponent.call(this, arguments);

        this.setActiveTab(0);
    },
  
    constructor : function(config) {
        config = Ext.apply({
            region:'east',
            width:400,
            split:true,
            autoDestroy:true,
            collapsible:true
        }, config);

        Compass.ErpApp.Desktop.Applications.Knitkit.EastRegion.superclass.constructor.call(this, config);
    }
});

Ext.reg('knitkit_eastregion', Compass.ErpApp.Desktop.Applications.Knitkit.EastRegion);
