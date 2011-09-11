Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.EastRegion",{
    extend:"Ext.TabPanel",
    alias:'widget.knitkit_eastregion',
    initComponent: function() {
        this.imageAssetsPanel = new Compass.ErpApp.Desktop.Applications.Knitkit.ImageAssetsPanel();
        this.widgetsPanel = new Compass.ErpApp.Desktop.Applications.Knitkit.WidgetsPanel();
        this.fileAssetsPanel = new Compass.ErpApp.Desktop.Applications.Knitkit.FileAssetsPanel(this.initialConfig['module']);
        this.items = [this.imageAssetsPanel.layout, this.fileAssetsPanel.layout, this.widgetsPanel.layout];

        this.callParent(arguments);
        this.setActiveTab(0);
    },
  
    constructor : function(config) {
        config = Ext.apply({
            id:'knitkitEastRegion',
			region:'east',
            width:300,
            split:true,
            autoDestroy:true,
            collapsible:true
        }, config);

        this.callParent([config]);
    }
});
