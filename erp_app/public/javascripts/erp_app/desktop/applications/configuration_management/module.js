Ext.define("Compass.ErpApp.Desktop.Applications.ConfigurationManagement",{
  extend:"Ext.ux.desktop.Module",
  id:'configuration_management-win',
  init : function(){
    this.launcher = {
      text: 'Configuration Management',
      iconCls:'icon-grid',
      handler: this.createWindow,
      scope: this
    }
  },

  createWindow : function(){
    var desktop = this.app.getDesktop();
    var win = desktop.getWindow('configuration_management');
    if(!win){

      var tabPanel = {
        xtype:'tabpanel',
        items:[
        {
          xtype:'configurationmanagement-configurationtreepanel',
          url:'/erp_app/desktop/configuration_management/configurations',
          rootText:'Configuration',
          title:'Configurations',
          width:'100%',
          height:'100%'
        },
        {
          xtype:'configurationmanagement-configurationtreepanel',
          url:'/erp_app/desktop/configuration_management/configuration_templates',
          rootText:'Templates',
          title:'Templates',
          width:'100%',
          height:'100%'
        },
        {
          xtype:'configurationmanagement-configurationtypespanel'
        }
        ]
      }

      win = desktop.createWindow({
        id: 'configuration_management',
        title:'Configuration Management',
        width:1000,
        height:540,
        iconCls: 'icon-grid',
        shim:false,
        animCollapse:false,
        constrainHeader:true,
        layout: 'fit',
        items:[tabPanel]
      });
    }
    win.show();
  }
});
