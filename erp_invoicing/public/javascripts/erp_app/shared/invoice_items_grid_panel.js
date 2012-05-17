Ext.define('Compass.ErpApp.Shared.InvoiceItem',{
  extend:'Ext.data.Model',
  fields:['item_description','quantity', 'id','created_at','amount', 'invoice_id'],
  validations:[
  {
    type:'presence',
    field:'item_description'
  },
  {
    type:'presence',
    field:'quantity'
  },
  {
    type:'presence',
    field:'amount'
  }
  ]
});

Ext.define("Compass.ErpApp.Shared.InvoiceItemsGridPanel",{
  extend:"Ext.grid.Panel",
  alias:'widget.shared-invoiceitemsgridpanel',
  title:'Invoice Items',
  initComponent : function(){
    this.callParent(this.arguemnts);
  },

  constructor : function(config) {
    var self = this;

    var store = Ext.create('Ext.data.Store', {
      fields:['item_description','quantity', 'id','created_at','amount'],
      autoLoad: false,
      autoSync: true,
      proxy: {
        type: 'rest',
        url:'/erp_invoicing/erp_app/shared/invoices/invoice_items',
        extraParams:{
          invoice_id:null
        },
        reader: {
          type: 'json',
          successProperty: 'success',
          idProperty: 'id',
          root: 'invoice_items',
          totalProperty:'totalCount',
          messageProperty: 'messages'
        },
        writer: {
          type: 'json',
          writeAllFields:true,
          root: 'data'
        },
        listeners: {
          exception: function(proxy, response, operation){
            Ext.MessageBox.show({
              title: 'REMOTE EXCEPTION',
              msg: 'Error performing action please try again.',
              icon: Ext.MessageBox.ERROR,
              buttons: Ext.Msg.OK
            });
          }
        }
      }
    });

    this.editingPlugin = Ext.create('Ext.grid.plugin.RowEditing', {
      clicksToMoveEditor: 1
    });

    config = Ext.apply({
      plugins:[this.editingPlugin],
      layout:'fit',
      columns: [
      {
        header:'Description',
        width:500,
        sortable: false,
        dataIndex: 'item_description',
        editor:{
          xtype:'textfield'
        }
      },
      {
        header:'Quantity',
        sortable: false,
        dataIndex: 'quantity',
        editor:{
          xtype:'numberfield'
        }
      },
      {
        header:'Amount',
        sortable: true,
        dataIndex: 'amount',
        editor:{
          xtype:'numberfield'
        }

      },
      {
        header: 'Created At',
        sortable: true,
        width:150,
        dataIndex: 'created_at',
        renderer: Ext.util.Format.dateRenderer('m/d/Y  H:i:s')
      }
      ],
      autoScroll:true,
      stripeRows: true,
      store:store,
      viewConfig:{
        loadMask:false,
        forceFit:true
      },
      tbar:{
        items:[{
          text: 'Add',
          xtype:'button',
          iconCls: 'icon-add',
          handler: function(button) {
            var grid = button.up('shared-invoiceitemsgridpanel');
            var edit = grid.editingPlugin;
            grid.store.insert(0, new Compass.ErpApp.Shared.InvoiceItem({invoice_id:grid.getStore().proxy.extraParams.invoice_id}));
            edit.startEdit(0,0);
          }
        },'-',
        {
          text: 'Delete',
          type:'button',
          iconCls: 'icon-delete',
          handler: function(button) {
            Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this invoice item?', function(btn){
              if(btn == 'no'){
                return false;
              }
              else
              {
                var selection = self.getView().getSelectionModel().getSelection()[0];
                if (selection) {
                  self.store.remove(selection);
                }
              }
            });
          }
        }]
      }
    }, config);

    this.callParent([config]);
  }
});