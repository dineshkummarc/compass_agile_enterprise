Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.QueriesMenuTreePanel",{
  extend:"Ext.tree.TreePanel",
  alias:'widget.railsdbadmin_queriestreemenu',

  constructor : function(config) {
    var self = this;

    config = Ext.apply({
      title:'Queries',
      autoScroll:true,
      store:Ext.create('Ext.data.TreeStore', {
        proxy: {
          type: 'ajax',
          url: '/rails_db_admin/erp_app/desktop/queries/saved_queries_tree'
        },
        root:{
          text: 'Queries',
          expanded: true,
          draggable:false,
          iconCls:'icon-content'
        }
      }),
      animate:false,
      listeners:{
        'itemclick':function(view, record, item, index, e){
          e.stopEvent();
          if(record.data.leaf){
            self.initialConfig.module.displayQuery(record.data.id);
          }
        },
        'itemcontextmenu':function(view, record, item, index, e){
          e.stopEvent();
          var contextMenu = null;
          if(record.data.leaf){
            contextMenu = new Ext.menu.Menu({
              items:[
              {
                text:"Execute",
                iconCls:'icon-settings',
                listeners:{
                  scope:record,
                  'click':function(){
                    self.initialConfig.module.displayAndExecuteQuery(record.data.id);
                  }
                }
              },
              {
                text:"Delete",
                iconCls:'icon-delete',
                listeners:{
                  scope:record,
                  'click':function(){
                    self.initialConfig.module.deleteQuery(record.data.id);
                  }
                }
              }
              ]
            });
          }
          else{
            contextMenu = new Ext.menu.Menu({
              items:[
              {
                text:"New Query",
                iconCls:'icon-new',
                listeners:{
                  'click':function(){
                    self.initialConfig.module.addNewQueryTab();
                  }
                }
              }
              ]
            });
          }
          contextMenu.showAt(e.xy);
        }
      }
    }, config);
        
    this.callParent([config]);
  }
});
