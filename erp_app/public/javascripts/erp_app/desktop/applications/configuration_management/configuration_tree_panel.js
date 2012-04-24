Ext.create('Ext.data.Store', {
  storeId: 'configurationmanagement-typesstore',
  fields: ['display', 'value'],
  data : [{
    "display":"Website",
    "value":"Website"
  }]
});

Ext.create('Ext.data.Store', {
  storeId: 'configurationmanagement-actionstore',
  fields: ['display', 'value'],
  data : [{
    "display":"Copy",
    "value":"copy"
  },
  {
    "display":"Clone",
    "value":"clone"
  }]
});

Ext.create('Ext.data.Store', {
  storeId: 'configurationmanagement-modelsstore',
  fields: ['description', 'id'],
  autoLoad:true,
  proxy: {
    type: 'ajax',
    url : '/erp_app/desktop/configuration_management/configurable_models',
    reader: {
      type: 'json',
      root: 'models'
    }
  }
});

Ext.create('Ext.data.Store', {
  storeId: 'configurationmanagement-templatesstore',
  fields: ['description', 'id'],
  autoLoad:true,
  proxy: {
    type: 'ajax',
    url : '/erp_app/desktop/configuration_management/configuration_templates_store',
    reader: {
      type: 'json',
      root: 'templates'
    }
  }
});

Ext.define("Compass.ErpApp.Desktop.Applications.ConfigurationManagement.ConfigurationTreePanel",{
  extend:"Ext.tree.Panel",
  alias:'widget.configurationmanagement-configurationtreepanel',
  setWindowStatus : function(status){
    this.findParentByType('statuswindow').setStatus(status);
  },

  clearWindowStatus : function(){
    this.findParentByType('statuswindow').clearStatus();
  },

  showCreateConfiguration : function(){
    var self = this;
    Ext.create("Ext.window.Window",{
      title:'Create Configuration',
      layout: 'fit',
      items: { 
        xtype: 'form',
        url:'/erp_app/desktop/configuration_management/create_configuration',
        border: false,
        items:[
        {
          xtype:'textfield',
          name: 'name',
          fieldLabel: 'Name'
        },
        {
          xtype:'combo',
          name: 'type',
          fieldLabel: 'Type',
          store: 'configurationmanagement-typesstore',
          displayField: 'display',
          queryMode: 'local',
          valueField: 'value'
        },
        {
          xtype:'combo',
          name: 'model',
          fieldLabel: 'Model',
          store: 'configurationmanagement-modelsstore',
          displayField: 'description',
          queryMode: 'local',
          valueField: 'id'
        },
        {
          xtype:'combo',
          name: 'template',
          fieldLabel: 'Template',
          store: 'configurationmanagement-templatesstore',
          displayField: 'description',
          queryMode: 'local',
          valueField: 'id'
        },
        {
          xtype:'combo',
          name: 'configuration_action',
          fieldLabel: 'Action',
          store: 'configurationmanagement-actionstore',
          displayField: 'display',
          queryMode: 'local',
          valueField: 'value'
        }
        ]
      },
      buttons:[
      {
        text:'Create',
        handler:function(btn){
          btn.up('window').down('form').submit({
            waitMsg:'Creating Configuration',
            reset:true,
            success:function(form, action){
              var obj = Ext.decode(action.response.responseText);
              if(obj.success){
                self.getStore().load({
                  node:self.getRootNode()
                });
                btn.up('window').close();
              }
              else{
                Ext.Msg.alert("Error", 'Error creating configuration');
              }
            },
            failure:function(form, action){
              Ext.Msg.alert("Error", 'Error creating configuration');
            }
          });
        }
      },
      {
        text:'Cancel',
        handler:function(btn){
          btn.up('window').close();
        }
      }
      ]
    }).show();
  },

  deleteConfiguration : function(record){
    var self = this;
    Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this Configuration?', function(btn){
      if(btn == 'no'){
        return false;
      }
      else
      if(btn == 'yes')
      {
        self.setWindowStatus('Deleting Configuration...');
        Ext.Ajax.request({
          url: '/erp_app/desktop/configuration_management/delete_configuration',
          method: 'POST',
          params:{
            id:record.data['modelId']
          },
          success: function(response) {
            self.clearWindowStatus();
            var obj = Ext.decode(response.responseText);
            if(obj.success){
              record.remove(true);
            }
            else{
              Ext.Msg.alert('Error', 'Error deleting Configuration');
            }
          },
          failure: function(response) {
            self.clearWindowStatus();
            Ext.Msg.alert('Error', 'Error deleting Configuration');
          }
        });
      }
    });
  },

  constructor : function(config) {
    var self = this;

    var store = Ext.create('Ext.data.TreeStore', {
      proxy: {
        type: 'ajax',
        url: config.url
      },
      root: {
        text: config.rootText,
        draggable:false
      },
      fields:[
      {
        name:'modelId'
      },
      {
        name:'type'
      },
      {
        name:'text'
      },
      {
        name:'iconCls'
      },
      {
        name:'leaf'
      }
      ]
    });

    config = Ext.apply({
      store:store,
      animate:false,
      autoScroll:true,
      tbar:{
        items:[
        {
          text:'Create Configuration',
          iconCls:'icon-add',
          scope:this,
          handler:function(){
            self.showCreateConfiguration();
          }
        }
        ]
      },
      enableDD:true,
      containerScroll: true,
      border: false,
      frame:true,
      listeners:{
        'itemcontextmenu':function(view, record, htmlItem, index, e){
          e.stopEvent();

          var items = [];

          if(record.data['type'] == 'Configuration'){
            items.push({
              iconCls:'icon-delete',
              text:'Delete',
              handler:function(btn){
                self.deleteConfiguration(record);
              }
            });
          }

          var contextMenu = Ext.create("Ext.menu.Menu",{
            items:items
          });
          contextMenu.showAt(e.xy);
        }
      }
    }, config);

    this.callParent([config]);
  }
});
