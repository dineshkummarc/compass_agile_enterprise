Ext.define("Compass.ErpApp.Desktop.Applications.ControlPanel",{
  extend:"Ext.ux.desktop.Module",
  requires:["Ext.window.MessageBox","Ext.tab.Panel"],
  id:"control-panel-win",
  init : function(){
    this.launcher = {
      text: 'Control Panel',
      iconCls:'icon-control_panel',
      handler : this.createWindow,
      scope: this
    }
  },
  createWindow : function(){
    var desktop = this.app.getDesktop();
    var win = desktop.getWindow('control_panel');
    if(!win){
      var tabPanel = Ext.create('Ext.tab.Panel',{
        items:[
        {
          xtype:'controlpanel_desktopmanagementpanel',
          listeners:{
            'activate':function(panel){
              panel.setup();
            }
          }
        },
        {
          xtype:'controlpanel_applicationmanagementpanel'
        },
        {
          xtype:'controlpanel_profilemanagementpanel'
        }
        ]
      });

      win = desktop.createWindow({
        id: 'control_panel',
        title:'Control Panel',
        width:550,
        height:550,
        iconCls: 'icon-control_panel',
        shim:false,
        animCollapse:false,
        constrainHeader:true,
        layout:'fit',
        items:[tabPanel]
      });

      tabPanel.setActiveTab(0);
    }
    win.show();
    return win;
  }
});


