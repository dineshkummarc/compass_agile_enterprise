Compass.ErpApp.Desktop.Applications.Scaffold.RoleTypeActiveExtGrid = Ext.extend(Compass.ErpApp.Shared.ActiveExt.ActiveExtGridPanel, {
    constructor : function(config){
        config = Ext.apply({
            title:'RoleType',
            modelUrl:'./scaffold/role_type/',
            editable:true,
            page:true,
            pageSize:30,
            displayMsg:'Displaying {0} - {1} of {2}',
            emptyMsg:'Empty'
        }, config);
        Compass.ErpApp.Desktop.Applications.Scaffold.RoleTypeActiveExtGrid.superclass.constructor.call(this, config);
    }
});

Ext.reg('role_type_activeextgrid', Compass.ErpApp.Desktop.Applications.Scaffold.RoleTypeActiveExtGrid);