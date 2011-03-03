Compass.ErpApp.Desktop.Applications.SystemManagement.PartyEditableGrid = Ext.extend(Compass.ErpApp.Shared.DynamicEditableGridLoaderPanel, {
    constructor : function(config){
        config = Ext.apply({
            title:'Party',
            xtype:'shared_dynamiceditablegridloaderpanel',
            editable:true,
            setupUrl:'./system_management/party/setup',
            dataUrl:'./system_management/party/data',
            page:true,
            pageSize:30,
            displayMsg:'Displaying {0} - {1} of {2}',
            emptyMsg:'Empty'
        }, config);
        Compass.ErpApp.Desktop.Applications.SystemManagement.PartyEditableGrid.superclass.constructor.call(this, config);
    }
});

Ext.reg('party_editablegrid', Compass.ErpApp.Desktop.Applications.SystemManagement.PartyEditableGrid);