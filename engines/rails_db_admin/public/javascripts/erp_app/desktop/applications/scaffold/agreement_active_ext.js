Compass.ErpApp.Desktop.Applications.Scaffold.AgreementActiveExtGrid = Ext.extend(Compass.ErpApp.Shared.ActiveExt.ActiveExtGridPanel, {
    constructor : function(config){
        config = Ext.apply({
            title:'Agreement',
            modelUrl:'./scaffold/agreement/',
            editable:true,
            page:true,
            pageSize:30,
            displayMsg:'Displaying {0} - {1} of {2}',
            emptyMsg:'Empty'
        }, config);
        Compass.ErpApp.Desktop.Applications.Scaffold.AgreementActiveExtGrid.superclass.constructor.call(this, config);
    }
});

Ext.reg('agreement_activeextgrid', Compass.ErpApp.Desktop.Applications.Scaffold.AgreementActiveExtGrid);