Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit",{
    extend:"Ext.ux.desktop.Module",
    id:'knitkit-win',
    init : function(){
        this.launcher = {
            text: 'KnitKit',
            iconCls:'icon-palette',
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
                height:550,
				maximized:true,
                iconCls: 'icon-palette',
                shim:false,
                animCollapse:false,
                constrainHeader:true,
                layout: 'border',
                items:[
                this.centerRegion,
                {
                    xtype:'knitkit_eastregion',
                    module:this
                },
                {
                    xtype:'knitkit_westregion',
                    centerRegion:this.centerRegion,
                    module:this
                }
            ]
            });
        }
        win.show();
    }
});
