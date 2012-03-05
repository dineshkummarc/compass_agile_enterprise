Ext.define("Compass.ErpApp.Organizer.Applications.BillPay.AccountDetailsPanel",{
  extend:"Ext.panel.Panel",
  alias:'widget.organizer-billpayaccountdetailspanel',
  constructor : function(config) {
    var southPanel = {
      xtype:'tabpanel',
      region:'south',
      height:300,
      split:true,
      collapsible:true,
      items:[{
        xtype:'shared-invoicesgridpanel',
        billingAccountNumber:config.billingAccountNumber,
        billingAccountId:config.billingAccountId,
        showAddDelete:true
      },{
        xtype:'billpay-paymentaccountsgridpanel',
        billingAccountNumber:config.billingAccountNumber,
        billingAccountId:config.billingAccountId
      }]
    };

    var billingAccount = config.billingAccount;
    var billing_account_details = new Ext.Template(["<div style=\"padding: 10px;\"> ",
        "Account Number: "+  billingAccount.get('account_number') +"<br>",
        "Send Paper Bills: "+  billingAccount.get('send_paper_bills') +"<br>",
        "Payable Online: "+  billingAccount.get('payable_online') +"<br>",
        "Calculate Balance: "+  billingAccount.get('calculate_balance') +"<br>",
        "Payment Due: "+  billingAccount.get('payment_due') +"<br>",
        "Balance: "+  billingAccount.get('balance') +"<br>",
        "Balance Date: "+  Ext.Date.format(billingAccount.get('balance_date'), 'm/d/Y') +"<br>",
        "Due Date: "+  Ext.Date.format(billingAccount.get('due_date'), 'm/d/Y') +"<br>",
        "</div>"]);   

    var centerPanel = {
      xtype:'panel',
      layout:'fit',
      region:'center',
      autoScroll:true,
      html:billing_account_details
    };

    config = Ext.apply({
      layout:'border',
      frame: false,
      autoScroll:true,
      region:'center',
      items:[
      centerPanel,
      southPanel
      ]

    }, config);
    this.callParent([config]);
  }

});

Compass.ErpApp.Organizer.Applications.BillPay.Base = function(config){

  //setup extensions
  //Compass.ErpApp.Organizer.Applications.BillPay.loadExtensions();

  var treeMenuStore = Ext.create('Compass.ErpApp.Organizer.DefaultMenuTreeStore', {
    url:'/erp_invoicing/erp_app/organizer/bill_pay/base/menu',
    rootText:'Menu',
    rootIconCls:'icon-content'
  });

  var menuTreePanel = {
    id:'billpaymenu',
    xtype:'defaultmenutree',
    title:'BillPay',
    store:treeMenuStore,
    menuRootIconCls:'icon-content',
    rootNodeTitle:'Menu',
    treeConfig:{
      store:treeMenuStore
    }
  };

  var tabPanel = {
    xtype:'tabpanel',
    title:'Bill Pay',
    itemId:'billpay-application',
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
    items:[{
      xtype:'shared-billingaccountsgridpanel',
      title:'Search',
      closable:false,
      autoLoad:false,
      listeners:{
        'itemdblclick':function(view, record, item, index, e, options){
          var tabPanel = view.ownerCt.up('tabpanel');
          var billingAccountNumber = record.get("account_number");
          var billingAccountId = record.get("id");
          var itemId = 'billingaccount'+billingAccountId;
          item = tabPanel.query('#'+itemId).first();

          if(Compass.ErpApp.Utility.isBlank(item)){
            item = Ext.create("widget.organizer-billpayaccountdetailspanel",{
              title:billingAccountNumber,
              closable:true,
              itemId:itemId,
              billingAccountId:billingAccountId,
              billingAccountNumber:billingAccountNumber,
              billingAccount: record
            });
            tabPanel.add(item);
          }

          tabPanel.setActiveTab(item);
          
        }
      }
    }]
  };

  this.setup = function(){
    config['organizerLayout'].addApplication(menuTreePanel, [tabPanel]);
  };

};

