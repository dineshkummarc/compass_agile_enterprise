Ext.ns("Compass.ErpApp.Desktop.Applications");

Compass.ErpApp.Desktop.Applications.Knitkit  = Ext.extend(Ext.app.Module, {
    id:'knitkit-win',
    init : function(){
        this.launcher = {
            text: 'KnitKit',
            iconCls:'icon-prodconfig',
            handler : this.createWindow,
            scope: this
        }
    },

    createWindow : function(){
        var desktop = this.app.getDesktop();
        var win = desktop.getWindow('knitkit');
        this.centerRegion = new Compass.ErpApp.Desktop.Applications.Knitkit.CenterRegion();
        if(!win){
            win = desktop.createWindow({
                id: 'knitkit',
                title:'KnitKit',
                autoDestroy:true,
                width:1200,
                height:800,
                iconCls: 'icon-prodconfig',
                shim:false,
                animCollapse:false,
                constrainHeader:true,
                layout: 'border',
                items:[this.centerRegion,{
                    xtype:'knitkit_eastregion',
                    module:this
                },{
                    xtype:'knitkit_westregion',
                    centerRegion:this.centerRegion,
                    module:this
                }]
            });
        }
        win.show();
    }
});
