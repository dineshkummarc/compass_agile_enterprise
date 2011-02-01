Compass.ErpApp.Desktop.Applications.Knitkit.WestRegion = Ext.extend(Ext.TabPanel, {
    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.Knitkit.WestRegion.superclass.initComponent.call(this, arguments);
    },
  
    constructor : function(config) {
        config = Ext.apply({
            region:'west',
            split:true,
            width:300,
            collapsible:true,
            items:[
            {
                xtype:'panel',
                title:'Web Sites'
            }
            ]
        }, config);

        Compass.ErpApp.Desktop.Applications.Knitkit.WestRegion.superclass.constructor.call(this, config);
    }
});

Ext.reg('knitkit_westregion', Compass.ErpApp.Desktop.Applications.Knitkit.WestRegion);
