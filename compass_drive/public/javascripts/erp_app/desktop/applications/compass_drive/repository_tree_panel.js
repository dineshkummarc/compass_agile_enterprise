Ext.define("Compass.ErpApp.Desktop.Applications.CompassDrive.RespositoryTreePanel",{
  extend:"Ext.tree.Panel",
  alias:'widget.compassdrive-repositorytreepanel',
  store:{
    proxy: {
      type: 'ajax',
      url: '/compass_drive/erp_app/desktop/index'
    },
    root: {
      text:'Repository'
    },
    fields:[
    {
      name:'modelId',
      type:'int'
    },
    {
      name:'text',
      type:'string'
    },
    {
      name:'iconCls',
      type:'string'
    },
    {
      name:'leaf',
      type:'boolean'
    },
    {
      name:'checkedOut',
      type:'boolean'
    },
    {
      name:'checkedOutBy',
      type:'string'
    },
    {
      name:'lastCheckoutOut',
      type:'date'
    }
    ]
  },
  listeners:{
    'itemcontextmenu':function(view, record, item, index, e, eOpts){
      e.stopEvent();

      if(record.isRoot()){
        
      }
    }
  },
  constructor: function(config) {

    this.callParent([config]);
  }
});

