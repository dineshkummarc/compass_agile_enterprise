Compass.ErpApp.Desktop.Applications.Knitkit.CenterRegion = Ext.extend(Ext.Panel, {
    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.Knitkit.CenterRegion.superclass.initComponent.call(this, arguments);
    },
  
    constructor : function(config) {
        config = Ext.apply({
            region:'center',
            split:true,
            items:[{
                xtype:'ckeditor',
                autoHeight:true,
                ckEditorConfig:{
                    toolbar:[['Source', '-', 'Bold', 'Italic', '-', 'NumberedList', 'BulletedList', '-', 'Link', 'Unlink','-','About']],
                    base_path:'/javascripts/ckeditor/'
                }
            }]
        }, config);

        Compass.ErpApp.Desktop.Applications.Knitkit.CenterRegion.superclass.constructor.call(this, config);
    }
});

Ext.reg('knitkit_centerregion', Compass.ErpApp.Desktop.Applications.Knitkit.CenterRegion);
