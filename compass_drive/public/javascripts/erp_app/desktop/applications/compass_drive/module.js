Ext.define("Compass.ErpApp.Desktop.Applications.CompassDrive",{
    extend:"Ext.ux.desktop.Module",
    id:'compass_drive-win',
    init : function(){
        this.launcher = {
            text: 'CompassDrive',
            iconCls:'icon-harddrive',
            handler: this.createWindow,
            scope: this
        }
    },

    createWindow : function(){
       var desktop = this.app.getDesktop();
        var win = desktop.getWindow('compass_drive');
        if(!win){
            win = desktop.createWindow({
                id: 'compass_drive',
                title:'CompassDrive',
                width:1000,
                height:550,
                iconCls: 'icon-harddrive',
                shim:false,
                animCollapse:false,
                constrainHeader:true,
                layout: 'fit',
                items:[]
            });
        }
        win.show();
    }
});
