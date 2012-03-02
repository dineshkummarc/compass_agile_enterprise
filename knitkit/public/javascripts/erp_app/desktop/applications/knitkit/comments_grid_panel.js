Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.CommentsGridPanel",{
  extend:"Ext.grid.Panel",
  alias:'widget.knitkit_commentsgridpanel',
  approve : function(rec){
    var self = this;
    self.initialConfig['centerRegion'].setWindowStatus('Approving Comment...');
    Ext.Ajax.request({
      url: '/knitkit/erp_app/desktop/comments/approve',
      method: 'POST',
      params:{
        id:rec.get("id")
      },
      success: function(response) {
        var obj = Ext.decode(response.responseText);
        if(obj.success){
          self.initialConfig['centerRegion'].clearWindowStatus();
          self.getStore().load();
        }
        else{
          Ext.Msg.alert('Error', 'Error approving comemnt');
          self.initialConfig['centerRegion'].clearWindowStatus();
        }
      },
      failure: function(response) {
        self.initialConfig['centerRegion'].clearWindowStatus();
        Ext.Msg.alert('Error', 'Error approving comemnt');
      }
    });

        
  },

  deleteComment : function(rec){
    var self = this;
    self.initialConfig['centerRegion'].setWindowStatus('Deleting Comment...');
    Ext.Ajax.request({
      url: '/knitkit/erp_app/desktop/comments/delete',
      method: 'POST',
      params:{
        id:rec.get("id")
      },
      success: function(response) {
        var obj =  Ext.decode(response.responseText);
        if(obj.success){
          self.initialConfig['centerRegion'].clearWindowStatus();
          self.getStore().load();
        }
        else{
          Ext.Msg.alert('Error', 'Error deleting comemnt');
          self.initialConfig['centerRegion'].clearWindowStatus();
        }
      },
      failure: function(response) {
        self.initialConfig['centerRegion'].clearWindowStatus();
        Ext.Msg.alert('Error', 'Error deleting comemnt');
      }
    });


  },

  initComponent: function() {
    this.callParent(arguments);
    this.getStore().load();
  },

  constructor : function(config) {
    var self = this;

    var store = Ext.create('Ext.data.Store', {
      proxy: {
        type: 'ajax',
        url:'/knitkit/erp_app/desktop/comments/index/' + config['contentId'],
        reader: {
          type: 'json',
          root: 'comments'
        }
      },
      remoteSort: true,
      fields:[
      {
        name:'id'
      },
      {
        name:'commentor_name'
      },
      {
        name:'email'
      },
      {
        name:'created_at'
      },
      {
        name:'approved?'
      },
      {
        name:'comment'
      },
      {
        name:'approved_by_username'
      },
      {
        name:'approved_at'
      }
      ]
    });

    config = Ext.apply({
      store:store,
      columns:[
      {
        header:'Commentor',
        sortable:true,
        width:150,
        dataIndex:'commentor_name'
      },
      {
        header:'Email',
        sortable:true,
        width:150,
        dataIndex:'email'
      },
      {
        header:'Commented On',
        dataIndex:'created_at',
        width:120,
        sortable:true,
        renderer: Ext.util.Format.dateRenderer('m/d/Y H:i:s')
      },
      {
        menuDisabled:true,
        resizable:false,
        xtype:'actioncolumn',
        header:'View',
        align:'center',
        width:50,
        items:[{
          icon:'/images/icons/document_view/document_view_16x16.png',
          tooltip:'View',
          handler :function(grid, rowIndex, colIndex){
            var rec = grid.getStore().getAt(rowIndex);
            self.initialConfig['centerRegion'].showComment(rec.get('comment'));
          }
        }]
      },
      {
        menuDisabled:true,
        resizable:false,
        xtype:'actioncolumn',
        header:'Approval',
        align:'center',
        width:60,
        items:[{
          getClass: function(v, meta, rec) {  // Or return a class from a function
            if (rec.get('approved?')) {
              this.items[0].tooltip = 'Approved';
              return 'approved-col';
            } else {
              this.items[0].tooltip = 'Approve';
              return 'approve-col';
            }
          },
          handler: function(grid, rowIndex, colIndex) {
            var rec = grid.getStore().getAt(rowIndex);
            if(rec.get('approved?')){
              return false;
            }
            else{
              self.approve(rec)
            }
          }
        }]
      },
      {
        header:'Approved By',
        sortable:true,
        width:140,
        dataIndex:'approved_by_username'
      },
      {
        header:'Approved At',
        sortable:true,
        width:140,
        dataIndex:'approved_at',
        renderer: Ext.util.Format.dateRenderer('m/d/Y H:i:s')
      },
      {
        menuDisabled:true,
        resizable:false,
        xtype:'actioncolumn',
        header:'Delete',
        align:'center',
        width:50,
        items:[{
          icon:'/images/icons/delete/delete_16x16.png',
          tooltip:'Delete',
          handler :function(grid, rowIndex, colIndex){
            var rec = grid.getStore().getAt(rowIndex);
            self.deleteComment(rec);
          }
        }]
      }
      ],
      bbar: Ext.create("Ext.PagingToolbar",{
        pageSize: 10,
        store: store,
        displayInfo: true,
        displayMsg: '{0} - {1} of {2}',
        emptyMsg: "Empty"
      })
    }, config);

    this.callParent([config]);
  }
});