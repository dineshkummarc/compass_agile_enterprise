Ext.define("Compass.ErpApp.Shared.BillingAccountsGridPanel",{
  extend:"Compass.ErpApp.Shared.BillingAccountsGridPanel",
  alias:'widget.billpay',

initComponent : function(){
    this.setParams = function(params) {
      this.partyId = params.partyId;
      this.store.proxy.extraParams.party_id = params.partyId;
    };

    this.callParent(this.arguemnts);
  },

  constructor : function(config) {
    var self = this;

    var store = Ext.create('Ext.data.Store', {
      fields:['id', 'account_number', 'calculate_balance', 'payment_due','balance', {
        name:'due_date',
        type:'date',
        dateFormat:'Y-m-d'
      }, {
        name:'balance_date',
        type:'date',
        dateFormat:'Y-m-d'
      },'payable_online','send_paper_bills'],
      autoLoad: Compass.ErpApp.Utility.isBlank(config.autoLoad) ? true : config.autoLoad,
      autoSync: true,
      proxy: {
        type: 'rest',
        url:'/erp_invoicing/erp_app/shared/billing_accounts/index',
        extraParams:{
          account_number:null
        },
        reader: {
          type: 'json',
          successProperty: 'success',
          idProperty: 'id',
          root: 'billing_accounts',
          totalProperty:'totalCount',
          messageProperty: 'messages'
        },
        writer: {
          type: 'json',
          writeAllFields:true,
          root: 'billingAccount'
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

    var tbar = {
      items:[]
    };

    var billingAccountFormFields = [{
          xtype:'textfield',
          fieldLabel:'Account Number',
          allowBlank:false,
          name:'account_number'
        },
        {
          xtype:'checkbox',
          fieldLabel:'Send Paper Bills',
          name:'send_paper_bills',
          inputValue: 1,
          uncheckedValue: 0
        },      
        {
          xtype:'checkbox',
          fieldLabel:'Payable Online',
          name:'payable_online',
          inputValue: 1,
          uncheckedValue: 0
        },
        {
          xtype:'checkbox',
          fieldLabel:'Calculate Balance',
          name:'calculate_balance',
          inputValue: 1,
          uncheckedValue: 0
        },
        {
          xtype:'datefield',
          fieldLabel:'Balance Date',
          name:'balance_date'
        },
        {
          xtype:'datefield',
          fieldLabel:'Due Date',
          name:'due_date'
        }];

    updateBillingAccountFields = [{
          xtype:'numberfield',
          fieldLabel:'Payment Due',
          name:'payment_due'
        },
        {
          xtype:'numberfield',
          fieldLabel:'Balance',
          name:'balance'
        }];

    var addBillingAccountWindow = Ext.create("Ext.window.Window",{
      layout:'fit',
      width:375,
      title:'New Billing Account',
      buttonAlign:'center',
      items: new Ext.FormPanel({
        labelWidth: 110,
        frame:false,
        bodyStyle:'padding:5px 5px 0',
        width: 425,
        url:'/erp_invoicing/erp_app/shared/billing_accounts/index',
        defaults: {
          width: 225
        },
        items: [ billingAccountFormFields]
      }),
      buttons: [{
        text:'Submit',
        listeners:{
          'click':function(button){
            var window = button.findParentByType('window');
            var formPanel = window.query('form')[0];
            formPanel.getForm().submit({
              method: 'POST',
              reset:true,
              params:{
                balance:0,
                payment_due:0,
                party_id: self.partyId
              },
              waitMsg:'Creating Billing Account',
              success:function(form, action){
                var response =  Ext.decode(action.response.responseText);
                Ext.Msg.alert("Status", "Billing account created successfully.");
                if(response.success){
                  addBillingAccountWindow.hide();
                  self.store.load();
                }
              },
              failure:function(form, action){
                var message = 'Error adding individual';
                if(action.response != null){
                  var response =  Ext.decode(action.response.responseText);
                  message = response.message;
                }
                Ext.Msg.alert("Status", message);
              }
            });
          }
        }
      },{
        text: 'Close',
        handler: function(){
          addBillingAccountWindow.hide();
        }
      }]
    });

    var editBillingAccountWindow = Ext.create("Ext.window.Window",{
      layout:'fit',
      width:375,
      title:'Update Billing Account',
      buttonAlign:'center',
      items: new Ext.FormPanel({
        id: 'editBillingAccountFormPanel',
        labelWidth: 110,
        frame:false,
        bodyStyle:'padding:5px 5px 0',
        width: 425,
        url:'/erp_invoicing/erp_app/shared/billing_accounts/index',
        defaults: {
          width: 225
        },
        items: [ billingAccountFormFields.concat(updateBillingAccountFields)]
      }),
      buttons: [{
        text:'Submit',
        listeners:{
          'click':function(button){
            var window = button.findParentByType('window');
            var formPanel = window.query('form')[0];
            formPanel.getForm().submit({
              method: 'PUT',
              reset:true,
              params:{
                id:self.getView().getSelectionModel().getSelection()[0].data.id,
                party_id: self.partyId
              },
              waitMsg:'Updating Billing Account',
              success:function(form, action){
                var response =  Ext.decode(action.response.responseText);
                Ext.Msg.alert("Status", "Billing account updated successfully.");
                if(response.success){
                  editBillingAccountWindow.hide();
                  self.store.load();
                }
              },
              failure:function(form, action){
                var message = 'Error updating individual';
                if(action.response != null){
                  var response =  Ext.decode(action.response.responseText);
                  message = response.message;
                }
                Ext.Msg.alert("Status", message);
              }
            });
          }
        }
      },{
        text: 'Close',
        handler: function(){
          editBillingAccountWindow.hide();
        }
      }]
    });

    tbar.items.push({
      text: 'Add',
      xtype:'button',
      iconCls: 'icon-add',
      handler: function(button) {
        var grid = button.up('shared-billingaccountsgridpanel');
        addBillingAccountWindow.show();
      }
    });

    tbar.items.push('-');
    tbar.items.push({
      text: 'Edit',
      xtype:'button',
      iconCls: 'icon-edit',
      handler: function(button) {
        var selection = self.getView().getSelectionModel().getSelection()[0];
        if (selection){
          Ext.getCmp('editBillingAccountFormPanel').getForm().loadRecord(selection); 
          editBillingAccountWindow.show();
        }else{
          Ext.Msg.alert('Error','Please select a Billing Account to edit.');
        }
      }
    });

    tbar.items.push('-');
    tbar.items.push({
      text: 'Delete',
      type:'button',
      iconCls: 'icon-delete',
      handler: function(button) {
        Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this billing account?', function(btn){
          if(btn == 'no'){
            return false;
          }
          else
          {
            var selection = self.getView().getSelectionModel().getSelection()[0];
            if (selection) {
              store.remove(selection);
            }
          }
        });
      }
    });

    tbar.items.push('|');
    
    tbar.items = tbar.items.concat([
      '<span class="x-btn-inner">Account Number:</span>',
      {
        xtype:'textfield',
        hideLabel:true,
        itemId:'accountNumberSearchTextField'
      },
      {
        text:'Search',
        iconCls:'icon-search',
        handler:function(btn){
          var grid = btn.up('shared-billingaccountsgridpanel');
          grid.store.proxy.extraParams.account_number = grid.query('#accountNumberSearchTextField').first().getValue();
          grid.store.load();
        }
      },
      '|',
      {
        text: 'All',
        xtype:'button',
        iconCls: 'icon-eye',
        handler: function(btn) {
          var grid = btn.up('shared-billingaccountsgridpanel');
          grid.store.proxy.extraParams.account_number = null;
          grid.store.load();
        }
      },
      '|',
      {
        text: 'Make Payment',
        xtype:'button',
        iconCls: 'icon-creditcards',
        handler: function(btn) {          
          var selection = self.getView().getSelectionModel().getSelection()[0];
          if (selection){
            var make_payment_window = Ext.create("Compass.ErpApp.Organizer.Applications.BillPay.MakePaymentWindow",{
              url: '/erp_invoicing/erp_app/organizer/bill_pay/accounts/make_payment_on_account',
              amount: selection.data.payment_due,
              billing_account_id: selection.data.id
            });
            make_payment_window.show();
          }else{
            Ext.Msg.alert('Error','Please select a Billing Account to make a payment on.');
          }
        }
      }]);

    config = Ext.apply({
      plugins:[],
      columns: [
      {
        header:'Account Number',
        width:300,
        dataIndex: 'account_number',
        editor:{
          xtype:'textfield'
        }
      },
      {
        header:'Send Paper Bills',
        width:100,
        sortable: false,
        dataIndex: 'send_paper_bills',
        renderer:function(v){
          var result = '';
          if(v){
            result = 'Yes';
          }
          else{
            result = 'No';
          }
          return result;
        },
        editor:{
          xtype:'combo',
          store:[[true,'Yes'],[false,'No']],
          forceSelection:true,
          triggerAction:'all'
        }
      },
      {
        header:'Payable Online',
        width:100,
        sortable: false,
        dataIndex: 'payable_online',
        renderer:function(v){
          var result = '';
          if(v){
            result = 'Yes';
          }
          else{
            result = 'No';
          }
          return result;
        },
        editor:{
          xtype:'combo',
          store:[[true,'Yes'],[false,'No']],
          forceSelection:true,
          triggerAction:'all'
        }
      },
      {
        header:'Calculate Balance',
        width:100,
        sortable: false,
        dataIndex: 'calculate_balance',
        renderer:function(v){
          var result = '';
          if(v){
            result = 'Yes';
          }
          else{
            result = 'No';
          }
          return result;
        },
        editor:{
          xtype:'combo',
          store:[[true,'Yes'],[false,'No']],
          forceSelection:true,
          triggerAction:'all'
        }
      },
      {
        header:'Payment Due',
        width:100,
        dataIndex: 'payment_due',
        renderer:function(v){
          return v.toFixed(2);
        },
        editor:{
          xtype:'numberfield'
        }
      },
      {
        header:'Balance',
        width:100,
        dataIndex: 'balance',
        renderer:function(v){
          return v.toFixed(2);
        },
        editor:{
          xtype:'numberfield'
        }
      },
      {
        header:'Balance Date',
        width:150,
        dataIndex: 'balance_date',
        renderer: Ext.util.Format.dateRenderer('m/d/Y'),
        editor:{
          xtype:'datefield'
        }
      },
      {
        header:'Due Date',
        width:150,
        dataIndex: 'due_date',
        renderer: Ext.util.Format.dateRenderer('m/d/Y'),
        editor:{
          xtype:'datefield'
        }
      }
      ],
      store:store,
      loadMask: true,
      autoScroll:true,
      stripeRows: true,
      tbar:tbar,
      bbar:Ext.create("Ext.PagingToolbar",{
        pageSize:50,
        store:store,
        displayInfo: true,
        displayMsg: '{0} - {1} of {2}',
        emptyMsg: "Empty"
      }),
      listeners: {
        'itemdblclick':function(view, record, item, index, e, options){
          // TODO: switch accordian
          Ext.getCmp('billpaymenu').expand();

          // switch card panel app
          Ext.getCmp('erp_app_viewport_center').layout.setActiveItem('billpay-application');

          // open account tab
          var tabPanel = Ext.getCmp('erp_app_viewport_center').query('#billpay-application').first();
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
    }, config);

    this.callParent([config]);
  }
});
