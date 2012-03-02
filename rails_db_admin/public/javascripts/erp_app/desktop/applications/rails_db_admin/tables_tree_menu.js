Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.TablesMenuTreePanel",{
  extend:"Ext.tree.TreePanel",
  alias:'widget.railsdbadmin_tablestreemenu',
  constructor : function(config) {
    var self = this;

    config = Ext.apply({
      title:'Tables',
      autoScroll:true,
      store:Ext.create('Ext.data.TreeStore', {
        proxy: {
          type: 'ajax',
          url: '/rails_db_admin/erp_app/desktop/base/tables'
        },
        root: {
          text: 'Tables',
          expanded:false,
          draggable:false,
          iconCls:'icon-content'
        },
        fields:[
        {
          name:'leaf'
        },

        {
          name:'iconCls'
        },

        {
          name:'text'
        },

        {
          name:'id'
        },

        {
          name:'isTable'
        }
        ]
      }),
      animate:false,
      listeners:{
        'itemcontextmenu':function(view, record, item, index, e){
          e.stopEvent();
          if(!record.data['isTable']){
            return false;
          }
          else{
            var contextMenu = new Ext.menu.Menu({
              items:[
              {
                text:"Select Top 50",
                iconCls:'icon-settings',
                listeners:{
                  scope:record,
                  'click':function(){
                    self.initialConfig.module.selectTopFifty(this.data.id);
                  }
                }
              },
              {
                text:"Edit Table Data",
                iconCls:'icon-edit',
                listeners:{
                  scope:record,
                  'click':function(){
                    self.initialConfig.module.getTableData(this.data.id);
                  }
                }
              }
              ]
            });
            contextMenu.showAt(e.xy);
          }
        }
      }
    }, config);

    this.callParent([config]);
  }
});
