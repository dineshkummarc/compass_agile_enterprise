Ext.define("Compass.ErpApp.Desktop.Applications.ConfigurationManagement.ConfigurationTreePanel",{
  extend:"Ext.tree.Panel",
  alias:'widget.configurationmanagement-configurationtreepanel',
  setWindowStatus : function(status){
    this.findParentByType('statuswindow').setStatus(status);
  },

  clearWindowStatus : function(){
    this.findParentByType('statuswindow').clearStatus();
  },

  addType : function(record){
    var self = this;
    Ext.create("Ext.window.Window",{
      title:'Add Configuration Type',
      items: {
        xtype: 'form',
        bodyPadding:5,
        url:'/erp_app/desktop/configuration_management/add_type',
        border: false,
        items:[
        {
          name:'configuration_id',
          xtype:'hidden',
          value:record.get('model_id')
        },
        {
          xtype:'combo',
          name: 'category_id',
          fieldLabel: 'Category',
          displayField: 'description',
          queryMode: 'local',
          valueField: 'category_id',
          store:'configurationmanagement-categoriesstore',
          listeners:{
            'select':function(combo, records, eOpts){
              Ext.getStore('configurationmanagement-typesstore').load({
                params:{
                  category_id:records.first().get('category_id')
                }
              });
              combo.up('form').down('#configurationTypeCombo').enable();
            }
          }
        },
        {
          xtype:'combo',
          name: 'type_id',
          itemId:'configurationTypeCombo',
          fieldLabel: 'Configuration Type',
          displayField: 'description',
          queryMode: 'local',
          disabled:true,
          valueField: 'id',
          store:'configurationmanagement-typesstore'
        }
        ]
      },
      buttons:[
      {
        text:'Add Type',
        handler:function(btn){
          btn.up('window').down('form').submit({
            waitMsg:'Adding Type',
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
                Ext.Msg.alert("Error", 'Error adding configuration type.');
              }
            },
            failure:function(form, action){
              Ext.Msg.alert("Error", 'Error adding configuration type.');
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

  removeType : function(record){
    var self = this;
    Ext.Msg.confirm("Please Confirm", 'Are you sure you want remove this Configuration Type?',function(btn, text){
      if(btn == 'yes'){
        var waitMsg = Ext.Msg.wait('Status', 'Removing configuration type...')
        Ext.Ajax.request({
          url:'/erp_app/desktop/configuration_management/remove_type',
          params:{
            configuration_id:record.get('configuration_id'),
            type_id:record.get('model_id')
          },
          success:function(response){
            waitMsg.close();
            self.getStore().load({
              node:self.getRootNode()
            });
          },
          failure:function(response){
            waitMsg.close();
            Ext.Msg.alert('Error', 'There was an error removing the configuration type.');
          }
        });
      }
    });
  },

  showCreateConfiguration : function(){
    var self = this;
    Ext.create("Ext.window.Window",{
      title:'Create Configuration',
      items: {
        xtype: 'form',
        bodyPadding:5,
        url:'/erp_app/desktop/configuration_management/create_configuration',
        border: false,
        items:[
        {
          xtype:'textfield',
          name: 'name',
          width:400,
          fieldLabel: 'Name',
          allowBlank:false
        },
        {
          xtype:'combo',
          allowBlank:false,
          name: 'type',
          fieldLabel: 'Type',
          displayField: 'display',
          queryMode: 'local',
          valueField: 'value',
          store:{
            storeId: 'configurationmanagement-typesstore',
            fields: ['display', 'value'],
            data : [{
              "display":"Website",
              "value":"Website"
            }]
          }
        },
        {
          xtype:'combo',
          allowBlank:false,
          name: 'model',
          width:400,
          fieldLabel: 'Model',
          store: 'configurationmanagement-modelsstore',
          displayField: 'description',
          valueField: 'id'
        },
        {
          xtype:'combo',
          allowBlank:false,
          name: 'template',
          width:400,
          fieldLabel: 'Template',
          store: 'configurationmanagement-templatesstore',
          displayField: 'description',
          valueField: 'id'
        },
        {
          xtype:'combo',
          allowBlank:false,
          name: 'configuration_action',
          fieldLabel: 'Action',
          displayField: 'display',
          queryMode: 'local',
          valueField: 'value',
          store:{
            fields: ['display', 'value'],
            data : [{
              "display":"Copy",
              "value":"copy"
            },
            {
              "display":"Clone",
              "value":"clone"
            }]
          }
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

  showCreateTemplate : function(){
    var self = this;
    Ext.create("Ext.window.Window",{
      title:'Create Template',
      items: {
        xtype: 'form',
        bodyPadding:5,
        url:'/erp_app/desktop/configuration_management/create_template',
        border: false,
        items:[
        {
          xtype:'textfield',
          name: 'name',
          width:400,
          fieldLabel: 'Name',
          allowBlank:false
        }
        ]
      },
      buttons:[
      {
        text:'Create',
        handler:function(btn){
          var form = btn.up('window').down('form').getForm();
          if(form.isValid()){
            form.submit({
              waitMsg:'Creating Template',
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
                  Ext.Msg.alert("Error", 'Error creating template');
                }
              },
              failure:function(form, action){
                Ext.Msg.alert("Error", 'Error creating template');
              }
            });
          }
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

  showCopyTemplate : function(){
    var self = this;
    Ext.create("Ext.window.Window",{
      title:'Copy Template',
      items: {
        xtype: 'form',
        bodyPadding:5,
        url:'/erp_app/desktop/configuration_management/copy_template',
        border: false,
        items:[
        {
          xtype:'textfield',
          name: 'name',
          width:400,
          fieldLabel: 'Name',
          allowBlank:false
        },
        {
          xtype:'combo',
          allowBlank:false,
          name: 'template',
          width:400,
          fieldLabel: 'Template',
          store: 'configurationmanagement-templatesstore',
          displayField: 'description',
          valueField: 'id'
        }
        ]
      },
      buttons:[
      {
        text:'Copy',
        handler:function(btn){
          var form = btn.up('window').down('form').getForm();
          if(form.isValid()){
            form.submit({
              waitMsg:'Copying Template',
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
                  Ext.Msg.alert("Error", 'Error copying template');
                }
              },
              failure:function(form, action){
                Ext.Msg.alert("Error", 'Error copying template');
              }
            });
          }
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
          url: '/erp_app/desktop/configuration_management/destroy',
          method: 'POST',
          params:{
            id:record.data['model_id']
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
        name:'model_id'
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
      },
      {
        name:'configuration_id'
      },
      {
        name:'isTemplate',
        type:'boolean'
      }
      ]
    });

    config = Ext.apply({
      store:store,
      animate:false,
      autoScroll:true,
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

            if(record.data['isTemplate']){
              items.push({
                iconCls:'icon-add',
                text:'Add Type',
                handler:function(btn){
                  self.addType(record);
                }
              });
            }
          }
          
          if(record.data['isTemplate'] && record.data["type"] == "ConfigurationType"){
            items.push({
              iconCls:'icon-delete',
              text:'Remove Type',
              handler:function(btn){
                self.removeType(record);
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
