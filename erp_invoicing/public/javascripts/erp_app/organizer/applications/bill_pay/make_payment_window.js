Ext.define("Compass.ErpApp.Organizer.Applications.BillPay.MakePaymentWindow",{
  extend:"Ext.window.Window",
  alias:'widget.billpay_makepaymentwindow',
  constructor : function(config) {
    config = Ext.apply({
      id: 'billpay_makepayment_window',
      layout:'fit',
      width:300,
      title:'Make Payment',
      iconCls:'icon-creditcards',
      buttonAlign:'center',
      plain: true,
      items: Ext.create('Ext.form.Panel',{
        id: 'billpay_makepayment_form',
        baseParams:{
          billing_account_id:config.billing_account_id
        },
        url:config['url'],
        items: [
        {
          xtype:'numberfield',
          value:config['amount'],
          fieldLabel:'Amount',
          name: 'amount'
        },
        {
          xtype:'combo',
          name:'payment_account_id',
          loadingText:'Retrieving Payment Accounts...',
          store:Ext.create('Ext.data.Store',{
            proxy:{
              type:'ajax',
              reader:{
                type:'json',
                root:'payment_accounts'
              },
              extraParams:{
                account_id:config.accountId
              },
              url:'/erp_invoicing/erp_app/organizer/bill_pay/accounts/payment_accounts'
            },
            fields:[
            'id',
            'description'
            ]
          }),
          forceSelection:true,
          editable:false,
          fieldLabel:'Payment Account',
          autoSelect:true,
          typeAhead: true,
          mode: 'remote',
          displayField:'description',
          valueField:'id',
          triggerAction: 'all',
          allowBlank:false
        }
        ]
      }),
      buttons: [{
        text:'Submit',
        listeners:{
          'click':function(button){
            var win = Ext.getCmp('billpay_makepayment_window');
            var formPanel = Ext.getCmp('billpay_makepayment_form');
            //formPanel.findById('credit_card_amount_hidden').setValue(formPanel.findById('credit_card_amount').getValue().replace("$","").replace(",",""));
            //if(win.validateCreditCardInfo(formPanel.getForm())){
              formPanel.getForm().submit({
                method:config['method'] || 'POST',
                waitMsg:'Processing Credit Card...',
                success:function(form, action){
                  var response =  Ext.decode(action.response.responseText);
                  //win.fireEvent('charge_response', win, response);
                  if (response.success == true){ win.destroy(); }
                  Ext.Msg.alert('Success','Payment Successful');
                },
                failure:function(form, action){
                  if(action.response != null){
                    var response =  Ext.decode(action.response.responseText);
                    //win.fireEvent('charge_failure', win, response);
                    Ext.Msg.alert('Error','Payment Failed');
                  }
                  else
                  {
                    Ext.Msg.alert("Error", 'Error Processing Credit Card');
                  }
                }
              });
            //}
          }
        }
      },
      {
        text: 'Cancel',
        listeners:{
          'click':function(button){
            var win = button.findParentByType('billpay_makepaymentwindow');
            win.destroy();
          }
        }
      }]
    }, config);

    this.callParent([config]);
  }

});


