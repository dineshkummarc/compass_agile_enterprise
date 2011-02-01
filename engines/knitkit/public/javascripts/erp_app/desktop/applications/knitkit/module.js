Ext.ns("Compass.ErpApp.Desktop.Applications");

Compass.ErpApp.Desktop.Applications.Knitkit  = Ext.extend(Ext.app.Module, {
    id:'knitkit-win',
    init : function(){
        this.launcher = {
            text: 'KnitKit',
            iconCls:'icon-globe',
            handler : this.createWindow,
            scope: this
        }
    },
    createWindow : function(){
        var desktop = this.app.getDesktop();
        var win = desktop.getWindow('knitkit');
        if(!win){
            win = desktop.createWindow({
                id: 'knitkit',
                title:'KnitKit',
                width:1000,
                height:500,
                iconCls: 'icon-globe',
                shim:false,
                animCollapse:false,
                constrainHeader:true,
                layout: 'border',
                items:[{ xtype:'knitkit_centerregion'},{xtype:'knitkit_eastregion'},{xtype:'knitkit_westregion'}]
            });
        }
        win.show();
    }
});
