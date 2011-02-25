Compass.ErpApp.Desktop.Applications.SystemManagement = Ext.extend(Ext.app.Module, {
    id:'system_management-win',
    init : function(){
        this.launcher = {
            text: 'System Management',
            iconCls:'icon-monitor',
            handler : this.createWindow,
            scope: this
        }
    },
    createWindow : function(){
        var desktop = this.app.getDesktop();
        var win = desktop.getWindow('system_management');
        if(!win){
            var tabPanel = new Ext.TabPanel({
                items:[
                {
                    title:'Roles',
                    xtype:'activeextgridpanel',
                    modelUrl:'./system_management/roles',
                    editable:true,
                    page:true,
                    pageSize:30,
                    displayMsg:'Displaying {0} - {1} of {2}',
                    emptyMsg:'Empty'
                },
                {
                    xtype:'systemmanagement_applicationrolemanagement'
                }
                ]
            })

            win = desktop.createWindow({
                id: 'system_management',
                title:'System Management',
                width:1000,
                height:550,
                iconCls: 'icon-monitor',
                shim:false,
                animCollapse:false,
                constrainHeader:true,
                layout: 'fit',
                items:[tabPanel]
            });

            tabPanel.setActiveTab(0);
        }
        win.show();
    }
});
