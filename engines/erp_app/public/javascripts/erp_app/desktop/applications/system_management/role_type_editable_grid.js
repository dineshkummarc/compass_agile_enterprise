Compass.ErpApp.Desktop.Applications.SystemManagement.RoleTypeEditableGrid = Ext.extend(Compass.ErpApp.Shared.DynamicEditableGridLoaderPanel, {
    constructor : function(config){
        config = Ext.apply({
            title:'RoleType',
            xtype:'shared_dynamiceditablegridloaderpanel',
            editable:true,
            setupUrl:'./system_management/role_type/setup',
            dataUrl:'./system_management/role_type/data',
            page:true,
            pageSize:30,
            displayMsg:'Displaying {0} - {1} of {2}',
            emptyMsg:'Empty'
        }, config);
        Compass.ErpApp.Desktop.Applications.SystemManagement.RoleTypeEditableGrid.superclass.constructor.call(this, config);
    }
});

Ext.reg('role_type_editablegrid', Compass.ErpApp.Desktop.Applications.SystemManagement.RoleTypeEditableGrid);