Ext.define("Compass.ErpApp.Desktop.Applications.InvoiceManagement",{
  extend:"Ext.ux.desktop.Module",
  id:'invoice_management-win',
  init : function(){
    this.launcher = {
      text: 'Invoice Management',
      iconCls:'icon-creditcards',
      handler: this.createWindow,
      scope: this
    }
  },

  createWindow : function(){
    var desktop = this.app.getDesktop();
    var win = desktop.getWindow('invoice_management');
    if(!win){

      win = desktop.createWindow({
        id: 'invoice_management',
        title:'Invoice Management',
        width:1200,
        height:800,
        iconCls: 'icon-creditcards',
        shim:false,
        animCollapse:false,
        constrainHeader:true,
        layout: 'fit',
        items:[
          {xtype:'tabpanel', items:[{xtype:'invoicemanagement-billingaccountspanel'},
          {xtype:'invoicemanagement_invoicespanel'}]}
        ]
      });
    }
    win.show();
  }
});

// fix for tempHidden in ExtJS 4.0.7 - Invoice Mgmt window was not opening correctly
// taken from http://www.sencha.com/forum/showthread.php?160222-quot-this.tempHidden-is-undefined-quot-Error-Workaround
Ext.override(Ext.ZIndexManager, {
    tempHidden: [],

    show: function() {
        var comp, x, y;

        while (comp = this.tempHidden.shift()) {
            x = comp.x;
            y = comp.y;

            comp.show();
            comp.setPosition(x, y);
        }
    }
});  
