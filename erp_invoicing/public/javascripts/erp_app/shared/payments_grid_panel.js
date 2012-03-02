Ext.define("Compass.ErpApp.Shared.PaymentsGridPanel",{
  extend:"Ext.grid.Panel",
  alias:'widget.shared-paymentsgridpanel',
  title:'Payments',
  initComponent : function(){
    this.callParent(this.arguemnts);
  },

  constructor : function(config) {
    var self = this;

    var store = Ext.create('Ext.data.Store', {
      fields:['payment_date','post_date', 'payment_account','amount'],
      autoLoad: false,
      proxy: {
        type: 'ajax',
        url:'/erp_invoicing/erp_app/shared/invoices/invoice_payments',
        reader: {
          type: 'json',
          root: 'payments'
        },
        extraParams:{
          invoice_id:null
        }
      },
      idProperty: 'id',
      remoteSort: true
    });

    config = Ext.apply({
      layout:'fit',
      columns: [
      {
        header:'Payment Date',
        sortable: false,
        width:150,
        dataIndex: 'payment_date',
        renderer: Ext.util.Format.dateRenderer('m/d/Y  H:i:s')
      },
      {
        header:'Post Date',
        sortable: false,
        width:150,
        dataIndex: 'post_date',
        renderer: Ext.util.Format.dateRenderer('m/d/Y  H:i:s')
      },
      {
        header:'Payment Account',
        sortable: false,
        width:150,
        dataIndex: 'payment_account'

      },
      {
        header: 'Amount',
        sortable: false,
        dataIndex: 'amount',
        renderer:function(v){
          return v.toFixed(2);
        }
      }
      ],
      autoScroll:true,
      stripeRows: true,
      store:store,
      viewConfig:{
        loadMask:false,
        forceFit:true
      }
    }, config);

    this.callParent([config]);
  }
});