Ext.ns("Compass.ErpApp.Desktop.Applications");

Compass.ErpApp.Desktop.Applications.Tenancy  = Ext.extend(Ext.app.Module, {
    id:'tenancy-win',
    init : function(){
        this.launcher = {
            text: 'Tenancy',
            iconCls:'icon-house',
            handler : this.createWindow,
            scope: this
        }
    },

    createWindow : function(){
        var desktop = this.app.getDesktop();
        var win = desktop.getWindow('tenancy');
        if(!win){		
            win = desktop.createWindow({
                id: 'tenancy',
                title:'Tenancy',
                width:400,
                height:550,
                iconCls: 'icon-house',
                shim:false,
                animCollapse:false,
                constrainHeader:true,
                layout: 'fit',
                items:[{xtype:'tenancy_tenanttree'}]
            });
            this.win = win;
        }
        win.show();
    }
});
