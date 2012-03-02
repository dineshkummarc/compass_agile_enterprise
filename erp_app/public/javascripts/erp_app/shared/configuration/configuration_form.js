Ext.regModel('Compass.ErpApp.Shared.ConfigurationOption', {
  fields: [
  {
    type: 'string',
    name: 'description'
  },
  {
    type: 'string',
    name: 'value'
  },
  {
    type: 'string',
    name: 'comment'
  }
  ]
});

Ext.define("Compass.ErpApp.Shared.ConfigurationForm",{
  extend:"Ext.form.Panel",
  alias:"widget.sharedconfigurationform",
  configurationItems:null,
  autoScroll:true,
  bodyStyle:'padding:5px 5px 0',
  frame:true,
  alreadySetup:false,
  border:false,
  fieldDefaults: {
    labelAlign: 'top'
  },
  //  layout: "table",
  //  items:[{
  //    itemId:'leftContainer',
  //    xtype: 'container',
  //    style: {padding:'5px','vertical-align':'top'},
  //    columnWidth:.5,
  //    layout: 'anchor'
  //  },{
  //    itemId:'rightContainer',
  //    xtype: 'container',
  //    style: {padding:'5px','vertical-align':'top'},
  //    columnWidth:.5,
  //    layout: 'anchor'
  //  }],
  buttonAlign:'center',
  buttons:[
  {
    text:'Update',
    handler:function(button){
      var self = button.findParentByType('sharedconfigurationform');
      self.getForm().submit({
        reset:false,
        waitMsg:'Updating configuration...',
        success:function(form, action){
          var response = Ext.decode(action.response.responseText);
          var result = self.fireEvent('afterUpdate', self, response.configurationItems, action.response);
          if(result !== false){
            Ext.Msg.alert('Success', 'Configuration Saved');
          }
        },
        failure:function(form, action){
          var message = 'Error saving configuraiton.'
          Ext.Msg.alert("Status", message);
        }
      });
    }
  }],

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
    var self = this;
    var url = '/erp_app/shared/configuration/setup/' + self.initialConfig.configurationId
    if(!Compass.ErpApp.Utility.isBlank(self.initialConfig.categoryId)){
      url += '/' + self.initialConfig.categoryId;
    }
    this.disable();
    this.wait('Loading configuration...');
    Ext.Ajax.request({
      url:url,
      success: function(responseObject) {
        self.clearWait();
        var response = Ext.decode(responseObject.responseText);
        self.buildConfigurationForm(response.configurationItemTypes)
      },
      failure: function() {
        self.clearWait();
        Ext.Msg.alert('Status', 'Error setting up configruation.');
      }
    });
  },

  buildConfigurationForm: function(configurationItemTypes){
    var self = this;
    if(!self.alreadySetup){
      var result = this.fireEvent('beforeAddItemsToForm', self, configurationItemTypes);
      if(result !== false)
      {
        Ext.each(configurationItemTypes, function(configurationItemType){
          var field = null;
          if(configurationItemType.allowUserDefinedOptions){
            field = Ext.create('Ext.form.field.Text',{
              itemId:configurationItemType.internalIdentifier + '_id',
              fieldLabel:configurationItemType.description,
              name:configurationItemType.internalIdentifier,
              iconCls:'icon-add',
              width:150
            });
          }
          else
          {
            var store = Ext.create('Ext.data.Store',{data:[], model:'Compass.ErpApp.Shared.ConfigurationOption'});
            Ext.each(configurationItemType.configurationOptions,function(option){
              store.add({
                value:option.internalIdentifier,
                description:option.description,
                comment:option.comment
              });
            });
            if(configurationItemType.isMultiOptional){
              field = Ext.create('Ext.ux.form.MultiSelect',{
                itemId:configurationItemType.internalIdentifier + '_id',
                fieldLabel:configurationItemType.description,
                name:configurationItemType.internalIdentifier,
                displayField:'description',
                valueField:'value',
                width:150,
                queryMode: 'local',
                height:100,
                listConfig: {
                  getInnerTpl: function() {
                    return '<div data-qtip="{comment}">{description}</div>';
                  }
                },
                store:store
              });
            }
            else{ 
              field = Ext.create('Ext.form.field.ComboBox',{
                editable:false,
                forceSelection:true,
                itemId:configurationItemType.internalIdentifier + '_id',
                fieldLabel:configurationItemType.description,
                name:configurationItemType.internalIdentifier,
                width:150,
                displayField:'description',
                valueField:'value',
                queryMode: 'local',
                listConfig: {
                  getInnerTpl: function() {
                    return '<div data-qtip="{comment}">{description}</div>';
                  }
                },
                store:store
              });
            }
          }
          if(!configurationItemType.defaultOptions.empty()){
            field.value = configurationItemType.defaultOptions.collect('value');
          }
          self.add(field);
        });
      }
      self.alreadySetup = true;
      self.doLayout();
    }
    self.loadConfigurationItems();
  },

  loadConfigurationItems: function(){
    var self = this;
    var url = '/erp_app/shared/configuration/load/' + self.initialConfig.configurationId
    if(!Compass.ErpApp.Utility.isBlank(self.initialConfig.categoryId)){
      url += '/' + self.initialConfig.categoryId;
    }
    this.wait('Loading configuration...');
    Ext.Ajax.request({
      url:url,
      success: function(responseObject) {
        self.clearWait();
        var response = Ext.decode(responseObject.responseText);
        self.setConfigurationItems(response.configurationItems);
      },
      failure: function() {
        self.clearWait();
        Ext.Msg.alert('Status', 'Error loading configuration.');
      }
    });
  },

  setConfigurationItems: function(configurationItems){
    var self = this;
    self.configurationItems = configurationItems
    var result = this.fireEvent('beforeSetConfigurationItems', self, configurationItems);
    if(result !== false)
    {
      Ext.each(configurationItems, function(configruationItem){
        if(!configruationItem.configurationOptions.empty()){
          var id = '#' + configruationItem.configruationItemType.internalIdentifier + '_id';
          var comp = self.query(id).first();
          if(configruationItem.configruationItemType.allowUserDefinedOptions){
            comp.setValue(configruationItem.configurationOptions.first().value);
          }
          else if(configruationItem.configruationItemType.isMultiOptional){
            var values = configruationItem.configurationOptions.collect('internalIdentifier');
            comp.setValue(values);
          }
          else{
            if(!configruationItem.configurationOptions.empty()){
              comp.setValue(configruationItem.configurationOptions.first().internalIdentifier)
            }
          }
        }
      });
    }
    this.fireEvent('afterSetConfigurationItems', self, configurationItems);
    self.enable();
  },
  
  initComponent: function() {
    this.addEvents(
      /**
         * @event beforeAddItemsToForm
         * Fired before loaded configuration item types a added to form before layout is called
         * if false is returned items are not added to form
         * @param {FormPanel} this
         * @param {Array} array of configurationItemTypes
         */
      "beforeAddItemsToForm",
      /**
         * @event beforeSetConfigurationItems
         * Fired brefore fields are set with configuration options
         * @param {FormPanel} this
         * @param {Array} array of configurationItems
         */
      "beforeSetConfigurationItems",
      /**
         * @event afterSetConfigurationItems
         * Fired after fields have been set with configuration options
         * @param {FormPanel} this
         * @param {Array} array of configurationItems
         */
      "afterSetConfigurationItems",
      /**
         * @event afterUpdate
         * Fired after update of configuration items
         * @param {FormPanel} this
         * @param {Array} array of updated configurationItems
         */
      "afterUpdate"
      );

    this.callParent(arguments);
  },

  constructor : function(config) {
    config = Ext.apply({
      url:'/erp_app/shared/configuration/update/' + config.configurationId
    }, config);

    this.callParent([config]);
  }
});
