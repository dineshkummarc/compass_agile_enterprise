
Compass.RailsDbAdmin.ReadOnlyTableDataGrid = Ext.extend(Ext.grid.GridPanel, {
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
        Compass.RailsDbAdmin.ReadOnlyTableDataGrid.superclass.constructor.call(this, config);
    }
});

Ext.reg('readonlytabledatagrid', Compass.RailsDbAdmin.ReadOnlyTableDataGrid);





