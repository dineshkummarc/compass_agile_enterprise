Ext.define("Compass.ErpApp.Desktop.Applications.DynamicForms.WestRegion",{
  extend:"Ext.tab.Panel",
  alias:'widget.dynamic_forms_westregion',
  setWindowStatus : function(status){
    this.findParentByType('statuswindow').setStatus(status);
  },
    
  clearWindowStatus : function(){
    this.findParentByType('statuswindow').clearStatus();
  },

  deleteModel : function(node){
    var self = this;
    Ext.MessageBox.confirm('Confirm',
      'Are you sure you want to delete this dynamic form model? WARNING: All forms belonging to this model will be deleted and any/all data will be orphaned!',
      function(btn){
        if(btn == 'no'){
          return false;
        }
        else if(btn == 'yes')
        {
          self.setWindowStatus('Deleting Dynamic Model...');
          Ext.Ajax.request({
            url: '/erp_forms/erp_app/desktop/dynamic_forms/models/delete',
            method: 'POST',
            params:{
              id:node.data.modelId
            },
            success: function(response) {
              self.clearWindowStatus();
              var obj =  Ext.decode(response.responseText);
              if(obj.success){
                //node.remove(true); // remove node causing a reload of entire tree with error, so we are going to simply reload tree for now
                self.sitesTree.getStore().load({
                  node: self.sitesTree.getRootNode()
                });
              }
              else{
                Ext.Msg.alert('Error', 'Error deleting model');
              }
            },
            failure: function(response) {
              self.clearWindowStatus();
              Ext.Msg.alert('Error', 'Error deleting model');
            }
          });
        }
      });
  },

  deleteForm : function(node){
    var self = this;
    Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this form? WARNING: Data will be orphaned if there is no form for this model.', function(btn){
      if(btn == 'no'){
        return false;
      }
      else
      if(btn == 'yes')
      {
        self.setWindowStatus('Deleting form...');
        Ext.Ajax.request({
          url: '/erp_forms/erp_app/desktop/dynamic_forms/forms/delete',
          method: 'POST',
          params:{
            id:node.data.formId
          },
          success: function(response) {
            self.clearWindowStatus();
            var obj =  Ext.decode(response.responseText);
            if(obj.success){
              node.remove(true);
            }
            else{
              Ext.Msg.alert('Error', 'Error deleting form');
            }
          },
          failure: function(response) {
            self.clearWindowStatus();
            Ext.Msg.alert('Error', 'Error deleting form');
          }
        });
      }
    });
  },

  setDefaultForm : function(node){
    var self = this;
    self.setWindowStatus('Setting Default form...');
    Ext.Ajax.request({
      url: '/erp_forms/erp_app/desktop/dynamic_forms/models/set_default_form',
      method: 'POST',
      params:{
        id:node.data.formId,
        model_name:node.data.modelName
      },
      success: function(response) {
        self.clearWindowStatus();
        var obj =  Ext.decode(response.responseText);
        if(obj.success){
          //reload model tree node
          self.sitesTree.getStore().load({
            //                        node:node.parentNode
            });
          node.parentNode.expand();
        }
        else{
          Ext.Msg.alert('Error', 'Error setting default form');
        }
      },
      failure: function(response) {
        self.clearWindowStatus();
        Ext.Msg.alert('Error', 'Error setting default form');
      }
    });
  },

  getDynamicForm : function(record){
    var self = this;
    self.setWindowStatus('Loading dynamic form...');
    Ext.Ajax.request({
      url: '/erp_forms/erp_app/desktop/dynamic_forms/forms/get',
      method: 'POST',
      params:{
        id:record.get('formId')
      },
      success: function(response) {
        self.initialConfig['centerRegion'].editSectionLayout(
          sectionName,
          websiteId,
          sectionId,
          response.responseText,
          [{
            text: 'Insert Content Area',
            handler: function(btn){
              var codeMirror = btn.findParentByType('codemirror');
              Ext.MessageBox.prompt('New File', 'Please enter content area name:', function(btn, text){
                if(btn == 'ok'){
                  codeMirror.insertContent('<%=render_content_area(:'+text+')%>');
                }

              });
            }
          }]);
        self.clearWindowStatus();
      },
      failure: function(response) {
        self.clearWindowStatus();
        Ext.Msg.alert('Error', 'Error loading dynamic form.');
      }
    });
  },

  getDynamicData : function(record, title){
    var self = this;
    var centerRegionLayout = Ext.create("Ext.panel.Panel",{
      layout:'border',
      title: record.data.text + " Dynamic Data",
      closable:true,
      items:[
      {
        xtype:'dynamic_forms_DynamicDataGridPanel',
        model_name:record.data.text,
        dataUrl: '/erp_forms/erp_app/desktop/dynamic_forms/data/index/'+record.data.text,
        setupUrl: '/erp_forms/erp_app/desktop/dynamic_forms/data/setup/'+record.data.text,
        region:'center',
        height:300,
        collapsible:false,
        centerRegion:self
      }],
      tbar:{
        items:[
        {
          text: "New " + record.data.text + " Record",
          iconCls:'icon-add',
          handler:function(btn){
            self.setWindowStatus('Getting form...');
            Ext.Ajax.request({
              url: '/erp_forms/erp_app/desktop/dynamic_forms/forms/get',
              method: 'POST',
              params:{
                model_name:record.data.text,
                form_action: 'create'
              },
              success: function(response) {
                self.clearWindowStatus();
                form_definition = Ext.decode(response.responseText);
                var newRecordWindow = Ext.create("Ext.window.Window",{
                  layout:'fit',
                  title:'New Record',
                  y: 100, // this fixes chrome and safari rendering the window at the bottom of the screen
                  plain: true,
                  buttonAlign:'center',
                  items: form_definition
                });
                newRecordWindow.show();
              },
              failure: function(response) {
                self.clearWindowStatus();
                Ext.Msg.alert('Error', 'Error getting form');
              }
            });
          }
        }
        ]
      }
    });

    this.centerRegion.workArea.add(centerRegionLayout);
    this.centerRegion.workArea.setActiveTab(this.centerRegion.workArea.items.length - 1);
  },
    
  initComponent: function() {
    var self = this;
        
    var store = Ext.create('Ext.data.TreeStore', {
      proxy:{
        type: 'ajax',
        url: '/erp_forms/erp_app/desktop/dynamic_forms/forms/get_tree'
      },
      root: {
        text: 'Dynamic Forms',
        expanded: true
      },
      fields:[
      {
        name:'id'
      },
      {
        name:'iconCls'
      },
      {
        name:'text',
        sortDir: 'ASC'
      },
      {
        name:'isModel'
      },
      {
        name:'modelName'
      },
      {
        name:'isDefault'
      },
      {
        name:'isForm'
      },
      {
        name:'modelId'
      },
      {
        name:'formId'
      },
      {
        name:'leaf'
      },
      {
        name:'children'
      }
      ],
      listeners:{
        // these listeners are a workaround for a extjs 4.0.7 bug
        // reference: http://www.sencha.com/forum/showthread.php?151211-Reloading-TreeStore-adds-all-records-to-store-getRemovedRecords&p=661157#post661157
        'beforeload': function()
        {
          this.clearOnLoad = false;
          this.getRootNode().removeAll();
        },
        'afterload': function()
        {
          this.removed = [];
        }
      }
    });

    this.sitesTree = new Ext.tree.TreePanel({
      store:store,
      dataUrl: '/erp_forms/erp_app/desktop/dynamic_forms/forms/get_tree',
      region: 'center',
      rootVisible:false,
      enableDD :false,
      listeners:{
        'load':function(){
          self.sitesTree.getStore().sort('text', 'ASC');
        },
        'itemclick':function(view, record, item, index, e){
          e.stopEvent();
          if(record.data['isModel']){
            if (record.data['children'].length > 0){
              self.getDynamicData(record);
            }
          }
          else if(record.data['isForm']){
            self.getDynamicForm(record);
          }
        },
        'itemcontextmenu':function(view, record, htmlItem, index, e){
          e.stopEvent();
          var items = [];

          if(record.data['isModel']){
                      
            // can only display data if there is a form to provide a definition
            if (record.data['children'].length > 0){
              items.push({
                text:'View Dynamic Data',
                iconCls:'icon-document',
                listeners:{
                  'click':function(){
                    self.getDynamicData(record);
                  }
                }
              });
            }

            items.push({
              text:'Add Dynamic Form',
              iconCls:'icon-add',
              listeners:{
                'click':function(){
                  //self.addDynamicForm(record);
                  Ext.Msg.alert('Info', 'Form Builder not yet implemented');
                }
              }
            });
                        
            if(record.data['text'] != 'DynamicFormDocument'){
              items.push({
                text:'Delete Model',
                iconCls:'icon-delete',
                listeners:{
                  'click':function(){
                    self.deleteModel(record);
                  }
                }
              });
            }
          }
          else if(record.data['isForm']){

            items.push({
              text:'Edit Dynamic Form',
              iconCls:'icon-edit',
              listeners:{
                'click':function(){
                  //self.getDynamicForm(record);
                  Ext.Msg.alert('Info', 'Form Builder not yet implemented');
                }
              }
            });
            if(!record.data['isDefault']){
              items.push({
                text:'Set As Default',
                iconCls:'icon-edit',
                listeners:{
                  'click':function(){
                    //self.setDefaultForm(record);
                    Ext.Msg.alert('Info', 'Form Builder not yet implemented');
                  }
                }
              });
            }

            items.push({
              text:'Delete',
              iconCls:'icon-delete',
              listeners:{
                'click':function(){
                  //self.deleteForm(record);
                  Ext.Msg.alert('Info', 'Form Builder not yet implemented');
                }
              }
            });
          }
                    
          var contextMenu = Ext.create("Ext.menu.Menu",{
            items:items
          });
          contextMenu.showAt(e.xy);
        }
      }
    });

    var layout = new Ext.Panel({
      layout: 'border',
      autoDestroy:true,
      title:'Dynamic Forms',
      items: [this.sitesTree],
      tbar:{
        items:[
        {
          text:'New Dynamic Form Model',
          iconCls:'icon-add',
          handler:function(btn){
            var newModelWindow = Ext.create("Ext.window.Window",{
              layout:'fit',
              width:375,
              title:'New Dynamic Form Model',
              height:100,
              plain: true,
              buttonAlign:'center',
              items: new Ext.FormPanel({
                labelWidth: 110,
                frame:false,
                fileUpload: true,
                bodyStyle:'padding:5px 5px 0',
                url:'/erp_forms/erp_app/desktop/dynamic_forms/models/create',
                defaults: {
                  width: 225
                },
                items: [
                {
                  xtype:'textfield',
                  fieldLabel:'Model Name',
                  allowBlank:false,
                  name:'model_name'
                }
                ]
              }),
              buttons: [{
                text:'Submit',
                listeners:{
                  'click':function(button){
                    var window = button.findParentByType('window');
                    var formPanel = window.query('form')[0];
                    self.setWindowStatus('Adding new dynamic form model ...');
                    formPanel.getForm().submit({
                      success:function(form, action){
                        self.clearWindowStatus();
                        var obj =  Ext.decode(action.response.responseText);
                        if(obj.success){
                          self.sitesTree.getStore().load({
                            node: self.sitesTree.getRootNode()
                          });
                          newModelWindow.close();
                        }
                        else{
                          Ext.Msg.alert("Error", obj.message);
                        }
                      },
                      failure:function(form, action){
                        self.clearWindowStatus();
                        var obj =  Ext.decode(action.response.responseText);
                        if(obj != null){
                          Ext.Msg.alert("Error", obj.message);
                        }
                        else{
                          Ext.Msg.alert("Error", "Error importing website");
                        }
                      }
                    });
                  }
                }
              },{
                text: 'Close',
                handler: function(){
                  newModelWindow.close();
                }
              }]
            });
            newModelWindow.show();
          }
        }
        ]
      }
    });

    this.items = [layout];
    this.callParent(arguments);
    this.setActiveTab(0);
  },

  constructor : function(config) {
    config = Ext.apply({
      id: 'westregionPanel',
      region:'west',
      split:true,
      width:200,
      collapsible:false
    }, config);

    this.callParent([config]);
  }
});
