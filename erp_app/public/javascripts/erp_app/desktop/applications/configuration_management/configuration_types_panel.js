
Ext.define("Compass.ErpApp.Desktop.Applications.ConfigurationManagement.ConfigurationTypesPanel",{
  extend:"Ext.panel.Panel",
  alias:'widget.configurationmanagement-configurationtypespanel',
  setWindowStatus : function(status){
    this.findParentByType('statuswindow').setStatus(status);
  },

  clearWindowStatus : function(){
    this.findParentByType('statuswindow').clearStatus();
  },

  editType : function(record){
    var form = this.down('form');
    form.query('#addTypeBtn').first().hide();
    form.query('#updateTypeBtn').first().show();
    this.down('form').loadRecord(record);
  },

  addType : function(record){
    var form = this.down('form');
    form.query('#addTypeBtn').first().show();
    form.query('#updateTypeBtn').first().hide();
    this.down('form').getForm().reset();
  },

  constructor : function(config) {
    var self = this;

    var typesForm = {
      xtype:'form',
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
        xtype:'radiogroup',
        fieldLabel:'Allow user defined options?',
        columns:[50,50],
        items:[
        {
          boxLabel:'Yes',
          name:'user_defined_options',
          inputValue: 'yes'
        },
        {
          boxLabel:'No',
          name:'user_defined_options',
          inputValue: 'no',
          checked:true
        }]
      },
      {
        xtype:'radiogroup',
        fieldLabel:'Is multi optional?',
        columns:[50,50],
        items:[
        {
          boxLabel:'Yes',
          name:'multi_optional',
          inputValue: 'yes'
        },

        {
          boxLabel:'No',
          name:'multi_optional',
          inputValue: 'no',
          checked:true
        }]
      }
      ],
      buttonAlign:'left',
      buttons:[
        {
          text:'Add Type',
          itemId:'addTypeBtn',
          hidden:false,
          handler:function(btn){

          }
        },
        {
          text:'Update Type',
          itemId:'updateTypeBtn',
          hidden:true,
          handler:function(btn){

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
          url: '/erp_app/desktop/configuration_management/types/index'
        },
        root: {
          text: 'Configuration Types',
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
        },
        {
          name:'description'
        },
        {
          name:'internal_identifier'
        },
        {
          name:'user_defined_options'
        },
        {
          name:'multi_optional'
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

          if(record.data['type'] == 'ConfigurationItemType'){
            items.push({
              iconCls:'icon-edit',
              text:'Edit',
              handler:function(btn){
                self.editType(record);
              }
            });

            items.push({
              iconCls:'icon-delete',
              text:'Delete',
              handler:function(btn){
                self.deleteType(record);
              }
            });

            items.push({
              iconCls:'icon-add',
              text:'Add Option',
              handler:function(btn){
                self.addOption(record);
              }
            });
          }

          if(record.data['type'] == 'ConfigurationOption'){
            items.push({
              iconCls:'icon-delete',
              text:'Remove',
              handler:function(btn){
                self.removeOption(record);
              }
            });
          }

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
      typesForm
      ],
      layout:'border',
      tbar:{
        items:[
        {
          text:'Add',
          iconCls:'icon-add',
          scope:this,
          handler:function(){
            self.addType();
          }
        }
        ]
      },
      title:'Types',
      frame:false,
      border:false
    }, config);

    this.callParent([config]);
  }
});
