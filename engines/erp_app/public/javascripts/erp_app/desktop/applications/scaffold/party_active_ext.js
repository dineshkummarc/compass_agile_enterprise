Compass.ErpApp.Desktop.Applications.Scaffold.PartyActiveExtGrid = Ext.extend(Compass.ErpApp.Shared.ActiveExt.ActiveExtGridPanel, {
    constructor : function(config){
        config = Ext.apply({
            title:'Party',
            modelUrl:'./scaffold/party/',
            editable:true,
            page:true,
            pageSize:30,
            displayMsg:'Displaying {0} - {1} of {2}',
            emptyMsg:'Empty'
        }, config);
        Compass.ErpApp.Desktop.Applications.Scaffold.PartyActiveExtGrid.superclass.constructor.call(this, config);
    }
});

Ext.reg('party_activeextgrid', Compass.ErpApp.Desktop.Applications.Scaffold.PartyActiveExtGrid);