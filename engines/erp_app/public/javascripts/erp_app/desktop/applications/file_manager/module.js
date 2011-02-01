Ext.ns("Compass.ErpApp.Desktop.Applications");

Compass.ErpApp.Desktop.Applications.FileManager  = Ext.extend(Ext.app.Module, {
    id:'file_manager-win',

    init : function(){
        this.launcher = {
            text: 'File Manager',
            iconCls:'icon-folders',
            handler : this.createWindow,
            scope: this
        }
    },
    createWindow : function(){
        var desktop = this.app.getDesktop();
        var win = desktop.getWindow('file_manager');
        if(!win){

            var ckEditorPanel = new Ext.Panel({
                region:'center',
                items:[{
                    xtype:'ckeditor',
                    autoHeight:true,
                    ckEditorConfig:{
                        toolbar:[['Source', '-', 'Bold', 'Italic', '-', 'NumberedList', 'BulletedList', '-', 'Link', 'Unlink','-','About'],'/',['CompassUploadFile']],
                        base_path:'../../javascripts/ckeditor/'
                    }
                }
                ]
            });

            var fileTreePanel = new Compass.ErpApp.Shared.FileManagerTree({
                xtype:'compassshared_filemanager',
                allowDownload:true,
                addViewContentsToContextMenu:true,
                elementToRenderContents:ckEditorPanel.findByType('ckeditor')[0],
                region:'west',
                rootVisible:true,
                loader: new Ext.tree.TreeLoader({
                    dataUrl:'./file_manager/base/expand_directory'
                }),
                containerScroll: true,
                border: false,
                width: 250,
                height: 300,
                frame:true
            }
            );

            win = desktop.createWindow({
                id: 'file_manager',
                title:'File Manager',
                width:1000,
                height:550,
                autoDestroy:true,
                iconCls: 'icon-folders',
                shim:false,
                animCollapse:false,
                constrainHeader:true,
                layout: 'border',
                items:[fileTreePanel,ckEditorPanel],
                listeners:{
                    'destroy':function(){
                        fileTreePanel.destroy();
                        ckEditorPanel.destroy();
                    }
                }
            //                tbar:{
            //                    items:[
            //                    {
            //                        iconCls: 'icon-upload',
            //                        text:'Upload Files',
            //                        handler:function(){
            //                            var uploadWindow = new Compass.ErpApp.Shared.UploadWindow();
            //                            uploadWindow.show();
            //                        }
            //                    }
            //                    ]
            //                }
            });
        }
        win.show();
        fileTreePanel.root.expand();
    }
});
