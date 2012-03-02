Ext.define("Compass.ErpApp.Organizer.Applications.BillPay.TransactionsGridPanel",{
  extend:"Ext.grid.Panel",
  alias:'widget.billpay_transactionsgridpanel',

  generateStatement : function(){
    window.open('/erp_invoicing/erp_app/organizer/bill_pay/accounts/generate_statement','mywindow','width=400,height=200');
  },

  initComponent : function(){
    this.bbar = Ext.create("Ext.PagingToolbar",{
      pageSize: this.initialConfig['pageSize'] || 50,
      store:this.store,
      displayInfo: true,
      displayMsg: '{0} - {1} of {2}',
      emptyMsg: "Empty"
    });

    this.callParent(arguments);
  },

  constructor : function(config) {
    var store = Ext.create("Ext.data.Store",{
      proxy:{
        type:'ajax',
        url: '/erp_invoicing/erp_app/organizer/bill_pay/accounts/transactions',
        reader:{
          type:'json',
          root: 'transactions'
        }
      },
      extraParams:{
        account_id:null
      },
      totalProperty: 'totalCount',
      idProperty: 'id',
      fields:[
      'date',
      'description',
      'amount'
      ]
    });

    config = Ext.apply({
     title:'Transactions',
     columns: [
      {
        header:'Transaction Date',
        sortable: true,
        dataIndex: 'date'
      },
      {
        header:'Description',
        sortable: true,
        width:150,
        dataIndex: 'description'
      },
      {
        header:'Amount',
        sortable: true,
        width:150,
        dataIndex: 'amount'
      },
      ],
      loadMask: true,
      autoScroll:true,
      stripeRows: true,
      store:store,
      tbar:{
        items:[
        {
          text: 'Generate Statement',
          xtype:'button',
          iconCls: 'icon-document',
          handler: function(btn) {
            btn.findParentByType('billpay_transactionsgridpanel').generateStatement();
          }
        },
        ]
      }
    }, config);

    this.callParent([config]);
  }
});