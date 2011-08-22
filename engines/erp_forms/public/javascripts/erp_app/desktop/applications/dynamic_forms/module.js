Ext.define("Compass.ErpApp.Desktop.Applications.DynamicForms",{
    extend:"Ext.ux.desktop.Module",
    id:'dynamic_forms-win',
    init : function(){
        this.launcher = {
            text: 'Dynamic Forms',
            iconCls:'icon-document',
            handler: this.createWindow,
            scope: this
        }
    },

    createWindow : function(){
       var desktop = this.app.getDesktop();
        var win = desktop.getWindow('dynamic_forms');
        this.centerRegion = new Compass.ErpApp.Desktop.Applications.DynamicForms.CenterRegion();                
        if(!win){
            win = desktop.createWindow({
                id: 'dynamic_forms',
                title:'Dynamic Forms',
                width:1150,
                height:550,
                iconCls: 'icon-document',
                shim:false,
                animCollapse:false,
                constrainHeader:true,
                layout: 'border',
                items:[this.centerRegion,{
                    xtype:'dynamic_forms_westregion',
                    centerRegion:this.centerRegion,
                    module:this
                }]
            });
        }
        win.show();
    }
});
