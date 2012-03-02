Ext.define("Compass.ErpApp.Desktop.Applications.InvoiceManagement.BillingAccountsPanel",{
  extend:"Ext.panel.Panel",
  alias:'widget.invoicemanagement-billingaccountspanel',
  title:'Billing Accounts',
    
  constructor : function(config) {
    var tabPanel = Ext.create("Ext.tab.Panel",{
      region:'south',
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
      height:250,
      split:true,
      collapsible:true,
      items:[]
    });

    config = Ext.apply({
      layout:'border',
      autoScroll:true,
      items:[
      {
        xtype:'shared-billingaccountsgridpanel',
        title:'',
        showAddDelete:true,
        region:'center',
        listeners:{
          'itemclick':function(view, record, item, index, e, options){
            var billingAccountNumber = record.get("account_number");
            var billingAccountId = record.get("id");
            var itemId = 'invoices-' + billingAccountId;
            var invoicesGridPanel = tabPanel.query('#'+itemId)[0];

            if(Compass.ErpApp.Utility.isBlank(invoicesGridPanel)){
              invoicesGridPanel = Ext.create('widget.shared-invoicesgridpanel',{
                billingAccountNumber:billingAccountNumber,
                billingAccountId:billingAccountId,
                itemId:itemId,
                showAddDelete:true,
                closable:true,
                title:billingAccountNumber + ' Invoices'
              });
              tabPanel.add(invoicesGridPanel);
            }
            else{
              invoicesGridPanel.store.load();
            }

            tabPanel.setActiveTab(invoicesGridPanel);
          }
        }
      },
      tabPanel]
    }, config);

    this.callParent([config]);
  }
    
});

