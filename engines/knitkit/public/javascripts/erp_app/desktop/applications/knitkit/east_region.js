Compass.ErpApp.Desktop.Applications.Knitkit.EastRegion = Ext.extend(Ext.TabPanel, {
    initComponent: function() {
        var imageAssetsPanel = new Compass.ErpApp.Desktop.Applications.Knitkit.ImageAssetsPanel();
        var fileAssetsPanel  = new Compass.ErpApp.Desktop.Applications.Knitkit.FileAssetsPanel(this.initialConfig['module']);
        this.items = [imageAssetsPanel.layout, fileAssetsPanel.layout];

        Compass.ErpApp.Desktop.Applications.Knitkit.EastRegion.superclass.initComponent.call(this, arguments);

        this.setActiveTab(0);
    },
  
    constructor : function(config) {
        config = Ext.apply({
            region:'east',
            width:300,
            split:true,
            autoDestroy:true,
            collapsible:true
        }, config);

        Compass.ErpApp.Desktop.Applications.Knitkit.EastRegion.superclass.constructor.call(this, config);
    }
});

Ext.reg('knitkit_eastregion', Compass.ErpApp.Desktop.Applications.Knitkit.EastRegion);
