Compass.ErpApp.Desktop.Applications.Scaffold.RoleActiveExtGrid = Ext.extend(Compass.ErpApp.Shared.ActiveExt.ActiveExtGridPanel, {
    constructor : function(config){
        config = Ext.apply({
            title:'Role',
            modelUrl:'./scaffold/role/',
            editable:true,
            page:true,
            pageSize:30,
            displayMsg:'Displaying {0} - {1} of {2}',
            emptyMsg:'Empty'
        }, config);
        Compass.ErpApp.Desktop.Applications.Scaffold.RoleActiveExtGrid.superclass.constructor.call(this, config);
    }
});

Ext.reg('role_activeextgrid', Compass.ErpApp.Desktop.Applications.Scaffold.RoleActiveExtGrid);