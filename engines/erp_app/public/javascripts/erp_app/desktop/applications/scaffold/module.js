Ext.ns("Compass.ErpApp.Desktop.Applications");

Compass.ErpApp.Desktop.Applications.Scaffold = Ext.extend(Ext.app.Module, {
    id:'scaffold-win',
    
    loadModel : function(modelName){
        //check if we are already showing this model
        var tab = null;
        var items = this.modelsTabPanel.items;
        Ext.each(items.items, function(item){
            if(item.xtype == modelName + '_activeextgrid'){
                tab = item;
            }
        });

        if(!Compass.ErpApp.Utility.isBlank(tab)){
            this.modelsTabPanel.setActiveTab(tab);
        }
        else{
            this.modelsTabPanel.add({
                xtype:modelName + '_activeextgrid',
                closable:true
            });
            this.modelsTabPanel.setActiveTab(this.modelsTabPanel.items.length - 1);
        }
    },

    init : function(){
        this.launcher = {
            text: 'Scaffold',
            iconCls:'icon-data',
            handler : this.createWindow,
            scope: this
        }
    },
    
    createWindow : function(){
        var desktop = this.app.getDesktop();
        var win = desktop.getWindow('scaffold');
        if(!win){
            this.modelsTabPanel = new Ext.TabPanel({
                region:'center'
            });

            win = desktop.createWindow({
                id: 'scaffold',
                title:'Scaffold',
                width:1000,
                height:550,
                iconCls: 'icon-data',
                shim:false,
                animCollapse:false,
                constrainHeader:true,
                layout: 'border',
                items:[{
                    xtype:'scaffold_modelstreepanel',
                    scaffold:this
                },this.modelsTabPanel]
            });
        }
        win.show();
    }
});
