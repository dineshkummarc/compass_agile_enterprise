Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.EastRegion",{
    extend:"Ext.TabPanel",
    alias:'widget.knitkit_eastregion',
    initComponent: function() {
        this.imageAssetsPanel = new Compass.ErpApp.Desktop.Applications.Knitkit.ImageAssetsPanel(this.initialConfig['module']);
        this.widgetsPanel = new Compass.ErpApp.Desktop.Applications.Knitkit.WidgetsPanel();
        this.fileAssetsPanel = new Compass.ErpApp.Desktop.Applications.Knitkit.FileAssetsPanel(this.initialConfig['module']);
        this.items = [];

        if (currentUser.hasApplicationCapability('knitkit', {
            capability_type_iid:'view',
            resource:'GlobalImageAsset'
        }) || currentUser.hasApplicationCapability('knitkit', {
            capability_type_iid:'view',
            resource:'SiteImageAsset'
        }))

        {
            this.items.push(this.imageAssetsPanel.layout)
        }

        if (currentUser.hasApplicationCapability('knitkit', {
            capability_type_iid:'view',
            resource:'GlobalFileAsset'
        }) || currentUser.hasApplicationCapability('knitkit', {
            capability_type_iid:'view',
            resource:'SiteFileAsset'
        }))

        {
            this.items.push(this.fileAssetsPanel.layout)
        }
        
        this.items.push(this.widgetsPanel.layout)

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
