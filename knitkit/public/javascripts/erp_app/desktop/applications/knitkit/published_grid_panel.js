Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.PublishedGridPanel",{
  extend:"Ext.grid.Panel",
  alias:'widget.knitkit_publishedgridpanel',
  initComponent: function() {
    this.callParent(arguments);
    this.getStore().load();
  },

  activate : function(rec){
    var self = this;
    Ext.Ajax.request({
      url: '/knitkit/erp_app/desktop/site/activate_publication',
      timeout: 90000,
      method: 'POST',
      params:{
        id:self.initialConfig.siteId,
        version:rec.get('version')
      },
      success: function(response) {
        var obj =  Ext.decode(response.responseText);
        var msg = "";
                if (obj.msg){
                    msg = obj.msg;
                }else{
                    msg = 'Error activating publication';
                }
        if(obj.success){
          self.getStore().load();
        }
        else{
          Ext.Msg.alert('Error', msg);
        }
      },
      failure: function(response) {
        Ext.Msg.alert('Error', 'Error activating publication');
      }
    });
  },

  setViewingVersion : function(rec){
    var self = this;
    Ext.Ajax.request({
      url: '/knitkit/erp_app/desktop/site/set_viewing_version',
      method: 'POST',
      params:{
        id:self.initialConfig.siteId,
        version:rec.get('version')
      },
      success: function(response) {
        var obj =  Ext.decode(response.responseText);
        if(obj.success){
          self.getStore().load();
        }
        else{
          Ext.Msg.alert('Error', 'Error setting viewing version');
        }
      },
      failure: function(response) {
        Ext.Msg.alert('Error', 'Error setting viewing version');
      }
    });
  },

  constructor : function(config) {
    var store = Ext.create("Ext.data.Store",{
      proxy:{
        type:'ajax',
        url:'/knitkit/erp_app/desktop/site/website_publications',
        reader:{
          type:'json',
          root:'data'
        },
        extraParams:{
          id:config['siteId']
        }
      },
      idProperty: 'id',
      remoteSort: true,
      fields: [
      {
        name:'id'
      },
      {
        name:'version',
        type: 'float'
      },
      {
        name:'created_at',
        type: 'date'
      },
      {
        name:'published_by_username'
      },
      {
        name:'comment'
      },
      {
        name:'active',
        type:'boolean'
      },
      {
        name:'viewing',
        type:'boolean'
      }
      ],
      listeners:{
        'exception':function(proxy, type, action, options, response, arg){
          Ext.Msg.alert('Error',arg);
        }
      }
    });

    config = Ext.apply({
      store:store,
      columns: [
      {
        header: "Version",
        sortable:true,
        width: 45,
        dataIndex: 'version'
      },
      {
        header: "Published",
        width: 117,
        sortable:true,
        renderer: Ext.util.Format.dateRenderer('m/d/Y H:i:s'),
        dataIndex: 'created_at'
      },
      {
        header: "Published By",
        width: 72,
        sortable:true,
        dataIndex: 'published_by_username'
      },
      {
        menuDisabled:true,
        resizable:false,
        xtype:'actioncolumn',
        header:'Viewing',
        align:'center',
        width:46,
        items:[{
          getClass: function(v, meta, rec) {  // Or return a class from a function
            if (rec.get('viewing')) {
              this.items[0].tooltip = 'Viewing';
              return 'viewing-col';
            } else {
              this.items[0].tooltip = 'View';
              return 'view-col';
            }
          },
          handler: function(grid, rowIndex, colIndex) {
            var rec = grid.getStore().getAt(rowIndex);
            if(rec.get('viewing')){
              return false;
            }
            else{
              grid.ownerCt.setViewingVersion(rec)
            }
          }
        }]
      },
      {
        menuDisabled:true,
        resizable:false,
        xtype:'actioncolumn',
        header:'Active',
        align:'center',
        width:44,
        items:[{
          getClass: function(v, meta, rec) {  // Or return a class from a function
            if (rec.get('active')) {
              this.items[0].tooltip = 'Active';
              return 'active-col';
            } else {
              this.items[0].tooltip = 'Activate';
              return 'activate-col';
            }
          },
          handler: function(grid, rowIndex, colIndex) {
             if (currentUser.hasApplicationCapability('knitkit', {
                            capability_type_iid:'activate',
                            resource:'Website'
                        }))
              {
              var rec = grid.getStore().getAt(rowIndex);
              if(rec.get('active')){
                return false;
              }
              else{
                grid.ownerCt.activate(rec)
              }
            }
            else{
              compassUser.showInvalidAccess();
            }
          }
        }]
      },
      {
        menuDisabled:true,
        resizable:false,
        xtype:'actioncolumn',
        header:'Note',
        align:'center',
        width:40,
        items:[{
          getClass: function(v, meta, rec) {  // Or return a class from a function
            this.items[0].tooltip = rec.get('comment');
            return 'info-col';
          },
          handler: function(grid, rowIndex, colIndex) {
            return false;
          }
        }]
      },
      ],
      bbar: new Ext.PagingToolbar({
        pageSize: 9,
        store:store,
        displayInfo: true,
        displayMsg: '{0} - {1} of {2}',
        emptyMsg: "Empty"
      })
    }, config);

    this.callParent([config]);
  }
});