Ext.define("Compass.ErpApp.Shared.ConfigurationPanel",{
  extend:"Ext.panel.Panel",
  alias:"widget.sharedconfigurationpanel",
  autoScroll:true,
  constructor: function(config){
    var categoriesTreePanel = {
      xtype:'treepanel',
      store:{
        proxy: {
          type: 'ajax',
          url: '/erp_app/shared/configuration/setup_categories/' + config.configurationId
        },
        autoLoad:true,
        root: {
          text: 'Categories',
          expanded: true
        },
        fields:[
        {
          name:'categoryId'
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
      },
      animate:false,
      autoDestroy:true,
      autoScroll:true,
      region:'west',
      containerScroll: true,
      border: false,
      width: 200,
      height: 400,
      frame:true,
      listeners:{
        'itemclick':function(view, record, item, index, e){
          e.stopEvent();
          var sharedConfigurationPanel = view.up('sharedconfigurationpanel');
          var tabPanel = sharedConfigurationPanel.query('#configurationFormsTabPanel').first();
          var itemId = 'configurationForm-'+record.get('categoryId');
          var configurationForm = tabPanel.query('#'+itemId).first();

          if(Ext.isEmpty(configurationForm)){
            configurationForm = {
              closable:true,
              xtype:'sharedconfigurationform',
              itemId:itemId,
              title:record.get('text'),
              configurationId:sharedConfigurationPanel.initialConfig.configurationId,
              categoryId:record.get('categoryId'),
              listeners:{
                activate:function(form){
                  form.setup();
                }
              }
            };
            tabPanel.add(configurationForm);
            configurationForm = tabPanel.query('#'+itemId).first();
          }
          tabPanel.setActiveTab(configurationForm);
        }
      }
    };

    var configurationFormsCardPanel = {
      xtype:'tabpanel',
      itemId:'configurationFormsTabPanel',
      region:'center',
      plugins: Ext.create('Ext.ux.TabCloseMenu', {
        extraItemsTail: [
        '-',
        {
          text: 'Closable',
          checked: true,
          hideOnClick: true,
          handler: function (item) {
            currentItem.tab.setClosable(item.checked);
          }
        }
        ],
        listeners: {
          aftermenu: function () {
            currentItem = null;
          },
          beforemenu: function (menu, item) {
            var menuitem = menu.child('*[text="Closable"]');
            currentItem = item;
            menuitem.setChecked(item.closable);
          }
        }
      }),
      width:400
    }

    config = Ext.apply({
      layout:'border',
      items:[categoriesTreePanel, configurationFormsCardPanel]
    },config);

    this.callParent([config]);
  }
});
