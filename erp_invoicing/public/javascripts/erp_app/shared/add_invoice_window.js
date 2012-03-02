Ext.define("Compass.ErpApp.Shared.AddInvoiceWindow",{
  extend:"Ext.window.Window",
  alias:'widget.shared-addinvoicewindow',
  initComponent : function() {
    this.addEvents(
      "create_success",
      "create_failure"
      );

    this.callParent(this.arguments);
  },
  constructor : function(config) {
    var form = Ext.create("Ext.form.Panel",{
      labelWidth:110,
      frame:false,
      bodyStyle:'padding:5px 5px 0',
      autoHeight:true,
      url:'/erp_invoicing/erp_app/shared/invoices/create_invoice',
      items: [{
        xtype: 'textfield',
        fieldLabel:'Invoice Number',
        name:'invoice_number',
        allowBlank:false
      },
      {
        xtype: 'textarea',
        height:100,
        fieldLabel:'Description',
        name:'description',
        allowBlank:false
      },
      {
        xtype: 'textarea',
        height:100,
        fieldLabel:'Message',
        name:'message',
        allowBlank:true
      },
      {
        xtype: 'datefield',
        fieldLabel:'Invoice Date',
        name:'invoice_date',
        allowBlank:false
      },
      {
        xtype: 'datefield',
        fieldLabel:'Due Date',
        name:'due_date',
        allowBlank:false
      }
      //        {
      //          xtype:'combo',
      //          hiddenName:'billed_from_party_id',
      //          name:'billed_from_party_id',
      //          loadingText:'Retrieving Parties...',
      //          store:Ext.create('Ext.data.Store',{
      //            proxy:{
      //              type:'ajax',
      //              reader:{
      //                type:'json',
      //                root:'parties'
      //              },
      //              url:'/erp_invoicing/erp_app/desktop/invoice_management/parties'
      //            },
      //            fields:[
      //            {
      //              name:'id'
      //            },
      //            {
      //              name:'description'
      //
      //            }
      //            ]
      //          }),
      //          forceSelection:true,
      //          editable:true,
      //          fieldLabel:'Billed From Party',
      //          autoSelect:true,
      //          typeAhead: true,
      //          mode: 'remote',
      //          displayField:'description',
      //          valueField:'id',
      //          triggerAction: 'all',
      //          allowBlank:true
      //        },
      //        {
      //          xtype:'combo',
      //          hiddenName:'billed_to_party_id',
      //          name:'billed_to_party_id',
      //          loadingText:'Retrieving Parties...',
      //          store:Ext.create('Ext.data.Store',{
      //            proxy:{
      //              type:'ajax',
      //              reader:{
      //                type:'json',
      //                root:'parties'
      //              },
      //              url:'/erp_invoicing/erp_app/desktop/invoice_management/parties'
      //            },
      //            fields:[
      //            {
      //              name:'id'
      //            },
      //            {
      //              name:'description'
      //
      //            }
      //            ]
      //          }),
      //          forceSelection:true,
      //          editable:true,
      //          fieldLabel:'Billed To Party',
      //          autoSelect:true,
      //          typeAhead: true,
      //          mode: 'remote',
      //          displayField:'description',
      //          valueField:'id',
      //          triggerAction: 'all',
      //          allowBlank:true
      //        }
      ]
    });

    if(!Compass.ErpApp.Utility.isBlank(config['billingAccountNumber'])){
      form.add({
        xtype:'displayfield',
        fieldLabel:'Billing Account',
        value:config['billingAccountNumber']
      });
      form.add({
        xtype:'hidden',
        name:'billing_account_id',
        value:config['billingAccountId']
      });
    }
    else{
      form.add({
        xtype:'combo',
        hiddenName:'billing_account_id',
        name:'billing_account_id',
        itemId:'billingAccountIdCombo',
        loadingText:'Retrieving Billing Accounts...',
        store:{
          autoLoad:true,
          xtype:'store',
          proxy:{
            type:'ajax',
            reader:{
              type:'json',
              root:'billing_accounts'
            },
            url:'/erp_invoicing/erp_app/shared/invoices/billing_accounts'
          },
          fields:[
          {
            name:'id'
          },
          {
            name:'account_number'
          }
          ]
        },
        forceSelection:true,
        editable:true,
        fieldLabel:'Billing Account',
        autoSelect:true,
        typeAhead: true,
        mode: 'remote',
        displayField:'account_number',
        valueField:'id',
        triggerAction: 'all',
        allowBlank:false
      });
    }

    config = Ext.apply({
      title:'Add Invoice',
      iconCls:'icon-add',
      buttonAlign:'center',
      plain: true,
      items: [form],
      buttons: [{
        text:'Submit',
        listeners:{
          'click':function(button){
            var win = button.findParentByType('shared-addinvoicewindow');
            var formPanel = win.query('form')[0];
            formPanel.getForm().submit({
              method:'POST',
              waitMsg:'Creating...',
              success:function(form, action){
                var response =  Ext.decode(action.response.responseText);
                win.fireEvent('create_success', win, response);
                win.close();
              },
              failure:function(form, action){
                Ext.Msg.alert('Error', 'Error creating invoice.');
              }
            });
          }
        }
      },
      {
        text: 'Cancel',
        listeners:{
          'click':function(button){
            var win = button.findParentByType('shared-addinvoicewindow');
            var form = win.query('form')[0];
            form.getForm().reset();
            win.close();
          }
        }
      }
      ]
    }, config);

    this.callParent([config]);
  }

});