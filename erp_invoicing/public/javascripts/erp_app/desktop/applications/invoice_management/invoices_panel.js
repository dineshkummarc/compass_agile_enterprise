Ext.define("Compass.ErpApp.Desktop.Applications.InvoiceManagement.InvoicesPanel",{
  extend:"Ext.panel.Panel",
  alias:'widget.invoicemanagement_invoicespanel',
  title:'Invoices',
  
  constructor : function(config) {
    var tabPanel = Ext.create("Ext.tab.Panel",{
      region:'south',
      height:250,
      split:true,
      collapsible:true,
      items:[
        {xtype:'shared-invoiceitemsgridpanel'},
        {xtype:'shared-paymentsgridpanel'}
      ]
    });

    config = Ext.apply({
      layout:'border',
      autoScroll:true,
      items:[{
        xtype:'shared-invoicesgridpanel',
        title:'',
        region:'center',
        showAddDelete:true,
        listeners:{
          'itemclick':function(view, record, item, index, e, options){
            var invoiceId = record.get("id");
            var itemsStore = tabPanel.query('shared-invoiceitemsgridpanel')[0].getStore();
            itemsStore.proxy.extraParams.invoice_id = invoiceId;
            itemsStore.load();

            var paymentsStore = tabPanel.query('shared-paymentsgridpanel')[0].getStore();
            paymentsStore.proxy.extraParams.invoice_id = invoiceId;
            paymentsStore.load();


            tabPanel.setActiveTab(0);
          }
        }
      },tabPanel]
    }, config);

    this.callParent([config]);
  }
    
});

