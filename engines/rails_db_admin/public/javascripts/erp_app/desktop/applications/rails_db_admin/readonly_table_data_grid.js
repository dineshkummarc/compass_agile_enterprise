
Compass.ErpApp.Desktop.Applications.RailsDbAdmin.ReadOnlyTableDataGrid = Ext.extend(Ext.grid.GridPanel, {
    constructor : function(config) {
       var jsonStore = new Ext.data.JsonStore({
           fields:config.fields,
           data:config.data
       })

       config = Ext.apply({
            store:jsonStore,
            layout:'fit',
            frame: false,
            closable: true,
            autoScroll:true,
            region:'center',
            loadMask:true
        }, config);
        Compass.ErpApp.Desktop.Applications.RailsDbAdmin.ReadOnlyTableDataGrid.superclass.constructor.call(this, config);
    }
});

Ext.reg('railsdbadmin_readonlytabledatagrid', Compass.ErpApp.Desktop.Applications.RailsDbAdmin.ReadOnlyTableDataGrid);





