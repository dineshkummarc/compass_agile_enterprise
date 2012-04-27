
Ext.define("Compass.ErpApp.Desktop.Applications.ConfigurationManagement.ConfigurationOptionsPanel",{
  extend:"Ext.panel.Panel",
  alias:'widget.configurationmanagement-configurationoptionspanel',
  setWindowStatus : function(status){
    this.findParentByType('statuswindow').setStatus(status);
  },

  clearWindowStatus : function(){
    this.findParentByType('statuswindow').clearStatus();
  },

  editOption : function(record){
    var form = this.down('form');
    form.query('#addOptionBtn').first().hide();
    form.query('#updateOptionBtn').first().show();
    this.down('form').loadRecord(record);
  },

  addOption : function(record){
    var form = this.down('form');
    form.query('#addOptionBtn').first().show();
    form.query('#updateOptionBtn').first().hide();
    this.down('form').getForm().reset();
  },

  deleteOption : function(record){
    var self = this;
    Ext.Msg.confirm("Please Confirm", 'Are you sure you want to delete this option?',function(btn, text){
      if(btn == 'yes'){
        Ext.Ajax.request({
          url:'/erp_app/desktop/configuration_management/options/destroy',
          params:{
            id:record.get('model_id')
          },
          success:function(response){
            self.down('treepanel').getStore().load();
          },
          failure:function(response){
            Ext.Msg.alert('Error', 'There was an error deleting the option.')
          }
        });
      }
    });
  },

  constructor : function(config) {
    var self = this;

    var optionsForm = {
      xtype:'form',
      url:'/erp_app/desktop/configuration_management/options/create_or_update',
      width:'50%',
      height:'50%',
      bodyPadding:10,
      region:'center',
      defaultType:'textfield',
      items:[
      {
        fieldLabel:'Description',
        width:400,
        name:'description'
      },
      {
        fieldLabel:'Internal Identifier',
        width:400,
        name:'internal_identifier'
      },
      {
        fieldLabel:'Value',
        width:400,
        name:'value'
      },
      {
        fieldLabel:'Comment',
        xtype:'textareafield',
        height:300,
        width:400,
        name:'comment'
      },
      {
        xtype:'hidden',
        name:'model_id'
      },
      ],
      buttonAlign:'left',
      buttons:[
      {
        text:'Add Option',
        itemId:'addOptionBtn',
        hidden:false,
        handler:function(btn){
          btn.up('form').getForm().submit({
            waitMsg:'Adding option...',
            reset:true,
            success:function(form, action){
              btn.up('configurationmanagement-configurationoptionspanel').down('treepanel').getStore().load();
            },
            failure:function(form, action){
              Ext.Msg.alert('Error', 'There was an error adding the option.')
            }
          });
        }
      },
      {
        text:'Update Option',
        itemId:'updateOptionBtn',
        hidden:true,
        handler:function(btn){
          btn.up('form').getForm().submit({
            waitMsg:'Updating option...',
            reset:true,
            success:function(form, action){
              btn.up('configurationmanagement-configurationoptionspanel').down('treepanel').getStore().load();
            },
            failure:function(form, action){
              Ext.Msg.alert('Error', 'There was an error updating option.')
            }
          });
        }
      }
      ]
    };

    var typesTree = {
      region:'west',
      width:'50%',
      xtype:'treepanel',
      store:{
        proxy: {
          type: 'ajax',
          url: '/erp_app/desktop/configuration_management/options/index.tree'
        },
        root: {
          text: 'Configuration Options',
          draggable:false
        },
        fields:[
        {
          name:'model_id'
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
          name:'description'
        },
        {
          name:'internal_identifier'
        },
        {
          name:'value'
        },
        {
          name:'comment'
        }
        ]
      },
      animate:false,
      autoScroll:true,
      enableDD:false,
      frame:true,
      listeners:{
        'itemcontextmenu':function(view, record, htmlItem, index, e){
          e.stopEvent();

          var items = [];

          items.push({
            iconCls:'icon-edit',
            text:'Edit',
            handler:function(btn){
              self.editOption(record);
            }
          });

          items.push({
            iconCls:'icon-delete',
            text:'Delete',
            handler:function(btn){
              self.deleteOption(record);
            }
          });
          
          var contextMenu = Ext.create("Ext.menu.Menu",{
            items:items
          });
          contextMenu.showAt(e.xy);
        }
      }
    }

    config = Ext.apply({
      items:[
      typesTree,
      optionsForm
      ],
      layout:'border',
      tbar:{
        items:[
        {
          text:'Add',
          iconCls:'icon-add',
          scope:this,
          handler:function(){
            self.addOption();
          }
        }
        ]
      },
      title:'Options',
      frame:false,
      border:false
    }, config);

    this.callParent([config]);
  }
});
