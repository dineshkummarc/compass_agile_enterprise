Ext.define("Compass.ErpApp.Organizer.Applications.BillPay.PaymentAccountsGridPanel",{
  extend:"Ext.grid.Panel",
  alias:'widget.billpay-paymentaccountsgridpanel',

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
        url: '/erp_invoicing/erp_app/organizer/bill_pay/accounts/payment_accounts',
        reader:{
          type:'json',
          root: 'payment_accounts'
        }
      },
      extraParams:{
        account_id:null
      },
      totalProperty: 'totalCount',
      idProperty: 'id',
      fields:[
      'id',
      'description',
      'account_type'
      ]
    });

    config = Ext.apply({
      title:'Payment Accounts',
      columns: [
      {
        header:'Description',
        sortable: true,
        dataIndex: 'description'
      },
      {
        header:'Account Type',
        sortable: true,
        width:150,
        dataIndex: 'account_type'
      },
      {
        menuDisabled:true,
        resizable:false,
        xtype:'actioncolumn',
        header:'Edit',
        align:'center',
        width:100,
        items:[{
          icon:'/images/icons/edit/edit_16x16.png',
          tooltip:'View Payor Info',
          handler :function(grid, rowIndex, colIndex){
           
          }
        }]
      },
      {
        menuDisabled:true,
        resizable:false,
        xtype:'actioncolumn',
        header:'Delete',
        align:'center',
        width:60,
        items:[{
          icon:'/images/icons/delete/delete_16x16.png',
          tooltip:'Delete',
          handler :function(grid, rowIndex, colIndex){
            
          }
        }]
      }
      ],
      loadMask: true,
      autoScroll:true,
      stripeRows: true,
      store:store,
      tbar:{
        items:[
        {
          text: 'Add',
          xtype:'button',
          iconCls: 'icon-add',
          handler: function(btn) {
            
          }
        }
        ]
      }
    }, config);

    this.callParent([config]);
  }
});