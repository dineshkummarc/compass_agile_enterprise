Ext.define("Compass.ErpApp.Desktop.Applications.Scaffold.RoleActiveExtGrid",{
    extend:"Compass.ErpApp.Shared.ActiveExt.ActiveExtGridPanel",
    alias:'widget.role_activeextgrid',
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

        this.callParent([config]);
    }
});