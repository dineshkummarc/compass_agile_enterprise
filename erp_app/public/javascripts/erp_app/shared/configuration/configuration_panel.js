Ext.define("Compass.ErpApp.Shared.ConfigurationPanel",{
  extend:"Ext.tab.Panel",
  alias:"widget.sharedconfigurationpanel",
  categories:null,
  autoScroll:true,
  items:[],
  wait : function(msg){
    this.waitMsg = Ext.MessageBox.show({
      msg: msg || 'Processing your request, please wait...',
      progressText: 'Working...',
      width:300,
      wait:true,
      waitConfig: {
        interval:200
      },
      iconCls:'icon-gear'
    });
       
  },

  clearWait : function(){
    this.waitMsg.hide();
  },

  setup: function(){
    this.disable();
    this.wait('Loading configuration...');
    var self = this;
    Ext.Ajax.request({
      url:'/erp_app/shared/configuration/setup_categories/' + self.initialConfig.configurationId,
      success: function(responseObject) {
        self.clearWait();
        var response = Ext.decode(responseObject.responseText);
        self.buildConfigurationPanels(response.categories);
        self.enable();
      },
      failure: function() {
        self.clearWait();
        Ext.Msg.alert('Status', 'Error setting up configruation.');
      }
    });
  },

  buildConfigurationPanels: function(categories){
    var self = this;
    Ext.each(categories, function(category){
      var configurationForm = Ext.create('Compass.ErpApp.Shared.ConfigurationForm',{
        title:category.description,
        configurationId:self.initialConfig.configurationId,
        categoryId:category.id,
        listeners:{
          activate:function(form){
            configurationForm.setup();
          }
        }
      });
      self.add(configurationForm);
      
    });
    self.doLayout();
  }
});
