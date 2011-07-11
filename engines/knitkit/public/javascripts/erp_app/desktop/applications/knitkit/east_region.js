Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.EastRegion",{
    extend:"Ext.TabPanel",
    alias:'widget.knitkit_eastregion',
    initComponent: function() {
        var imageAssetsPanel = new Compass.ErpApp.Desktop.Applications.Knitkit.ImageAssetsPanel();
        var widgetsPanel = new Compass.ErpApp.Desktop.Applications.Knitkit.WidgetsPanel();
        var fileAssetsPanel  = new Compass.ErpApp.Desktop.Applications.Knitkit.FileAssetsPanel(this.initialConfig['module']);
        this.items = [imageAssetsPanel.layout, fileAssetsPanel.layout, widgetsPanel.layout];

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
