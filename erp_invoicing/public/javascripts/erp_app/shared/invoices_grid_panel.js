Ext.define("Compass.ErpApp.Shared.InvoicesGridPanel",{
  extend:"Ext.grid.Panel",
  alias:'widget.shared-invoicesgridpanel',
  title:'Invoices',
  addDocument : function(rec){
    var uploadWindow = new Compass.ErpApp.Shared.UploadWindow({
      standardUploadUrl:'/erp_invoicing/erp_app/shared/invoices/files/'+rec.get('id')+'/upload_file',
      flashUploadUrl:'/erp_invoicing/erp_app/shared/invoices/files/'+rec.get('id')+'/upload_file',
      xhrUploadUrl:'/erp_invoicing/erp_app/shared/invoices/files/'+rec.get('id')+'/upload_file',
      extraPostData:{}
    });
    uploadWindow.show();
  },
  
  emailInvoice : function(rec){
    var emailInvoiceWindow = Ext.create("Ext.window.Window",{
      title:'Email Invoice',
      plain: true,
      buttonAlign:'center',
      items: {
        xtype: 'form',
        labelWidth: 110,
        frame:false,
        bodyStyle:'padding:5px 5px 0',
        width: 425,
        url:'/erp_invoicing/erp_app/shared/invoices/email_invoice',
        defaults: {
          width: 225
        },
        items: [
        {
          xtype:'textfield',
          fieldLabel:'Email Address',
          allowBlank:false,
          width:400,
          name:'to_email'
        },
        {
          xtype:'hiddenfield',
          name:'id',
          value:rec.get('id')
        }
        ]
      },
      buttons: [{
        text:'Submit',
        listeners:{
          'click':function(button){
            var window = button.findParentByType('window');
            var formPanel = window.query('form')[0];
            formPanel.getForm().submit({
              waitMsg:'Emailing Invoice',
              reset:true,
              success:function(form, action){
                var obj = Ext.decode(action.response.responseText);
                if(obj.success){
                  emailInvoiceWindow.close();
                  Ext.Msg.alert("Success", 'Email has been sent.');
                }
                else{
                  Ext.Msg.alert("Error", 'Error sending email.');
                }
              },
              failure:function(form, action){
                Ext.Msg.alert("Error", 'Error sending email.');
              }
            });
          }
        }
      },{
        text: 'Close',
        handler: function(){
          emailInvoiceWindow.close();
        }
      }]
    });
    emailInvoiceWindow.show();
  },

  sendSmsNotification : function(rec){
    Ext.MessageBox.confirm('Confirm', 'Are you sure you want to send a SMS notification', function(btn){
      if(btn == 'no'){
        return false;
      }
      else
      if(btn == 'yes')
      {
        var waitMsg = Ext.Msg.wait('Status','Sending SMS notification...');
        
        Ext.Ajax.request({
          url: '/erp_invoicing/erp_app/shared/invoices/sms_notification',
          method: 'POST',
          params:{
            id:rec.get('id')
          },
          success: function(response) {
            waitMsg.close();
            var obj =  Ext.decode(response.responseText);
            if(obj.success){
              Ext.Msg.alert('Success', 'SMS notification sent.');
            }
            else{
              Ext.Msg.alert('Error', 'Could not send notification');
            }
          },
          failure: function(response) {
            waitMsg.close();
            Ext.Msg.alert('Error', 'Could not send notification');
          }
        });
      }
    });
  },

  initComponent : function(){
    this.callParent(this.arguemnts);
  },

  constructor : function(config) {
    var self = this;
    
    var store = Ext.create('Ext.data.Store', {
      fields:['billed_to_party', 'billed_from_party', 'invoice_number','description', 'message', 'invoice_date', 'due_date', 'payment_due', 'id', 'billing_account'],
      autoLoad: Compass.ErpApp.Utility.isBlank(config['autoLoad']) ? true : config['autoLoad'],
      autoSync: true,
      proxy: {
        type: 'ajax',
        url:'/erp_invoicing/erp_app/shared/invoices/invoices',
        extraParams:{
          invoice_number:null,
          billing_account_id:config.billingAccountId
        },
        reader: {
          type: 'json',
          successProperty: 'success',
          idProperty: 'id',
          root: 'invoices',
          totalProperty:'totalCount',
          messageProperty: 'messages'
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
    if(config.showAddDelete){
      tbar.items.push({
        text: 'Add',
        xtype:'button',
        iconCls: 'icon-add',
        handler: function(button) {
          var grid = button.up('shared-invoicesgridpanel');
          var win = Ext.create("widget.shared-addinvoicewindow",{
            billingAccountNumber:grid.billingAccountNumber,
            billingAccountId:grid.billingAccountId,
            listeners:{
              'create_success':function(){
                store.load();
              }
            }
          });
          win.show();
        }
      });
      tbar.items.push('-');
      tbar.items.push({
        text: 'Delete',
        type:'button',
        iconCls: 'icon-delete',
        handler: function(button) {
          Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this invoice?', function(btn){
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
    }

    tbar.items = tbar.items.concat([
      '<span class="x-btn-inner">Invoice Number:</span>',
      {
        xtype:'numberfield',
        hideLabel:true,
        itemId:'invoiceNumberSearchNumberField'
      },
      {
        text:'Search',
        iconCls:'icon-search',
        handler:function(btn){
          var grid = btn.up('shared-invoicesgridpanel');
          var invoiceNumber = grid.query('#invoiceNumberSearchNumberField').first().getValue();
          grid.store.proxy.extraParams.invoice_number = invoiceNumber;
          grid.store.load();
        }
      },
      '|',
      {
        text: 'All',
        xtype:'button',
        iconCls: 'icon-eye',
        handler: function(btn) {
          var grid = btn.up('shared-invoicesgridpanel');
          grid.store.proxy.extraParams.invoice_number = null;
          grid.store.load();
        }
      },
      ]);

    config = Ext.apply({
      columns: [
      {
        header:'Invoice Number',
        sortable: true,
        dataIndex: 'invoice_number',
        editor:{
          xtype:'numberfield'
        }
      },
      {
        header:'Description',
        width:300,
        sortable: true,
        dataIndex: 'description'
      },
      {
        header:'Message',
        width:250,
        sortable: true,
        dataIndex: 'message'
      },
      {
        header:'Invoice Date',
        sortable: true,
        width:100,
        dataIndex: 'invoice_date',
        renderer: Ext.util.Format.dateRenderer('m/d/Y'),
        editor:{
          xtype:'datefield'
        }
      },
      {
        header:'Due Date',
        sortable: true,
        width:100,
        dataIndex: 'due_date',
        renderer: Ext.util.Format.dateRenderer('m/d/Y'),
        editor:{
          xtype:'datefield'
        }
      },
      {
        header:'Payment Due',
        sortable: false,
        width:100,
        dataIndex: 'payment_due',
        renderer:function(v){
          return v.toFixed(2);
        }
      },
      {
        header:'Billing Account',
        sortable: false,
        width:100,
        dataIndex: 'billing_account'
      },
      //      {
      //        header:'Billed To',
      //        sortable: false,
      //        width:100,
      //        dataIndex: 'billed_to_party'
      //      },
      //      {
      //        header:'Billed From',
      //        sortable: false,
      //        width:100,
      //        dataIndex: 'billed_from_party'
      //      },
      {
        menuDisabled:true,
        resizable:false,
        xtype:'actioncolumn',
        header:'SMS Notify',
        align:'center',
        width:100,
        items:[{
          icon:'/images/icons/message/message_16x16.png',
          tooltip:'Send SMS notification',
          handler :function(grid, rowIndex, colIndex){
            var rec = grid.getStore().getAt(rowIndex);
            self.sendSmsNotification(rec);
          }
        }]
      },
      {
        menuDisabled:true,
        resizable:false,
        xtype:'actioncolumn',
        header:'Email Invoice',
        align:'center',
        width:100,
        items:[{
          icon:'/images/icons/document/document_16x16.png',
          tooltip:'Email Invoice',
          handler :function(grid, rowIndex, colIndex){
            var rec = grid.getStore().getAt(rowIndex);
            self.emailInvoice(rec);
          }
        }]
      },
      {
        menuDisabled:true,
        resizable:false,
        xtype:'actioncolumn',
        header:'Add Document',
        align:'center',
        width:100,
        items:[{
          icon:'/images/icons/add/add_16x16.png',
          tooltip:'Add Document',
          handler :function(grid, rowIndex, colIndex){
            var rec = grid.getStore().getAt(rowIndex);
            self.addDocument(rec);
          }
        }]
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
      })
    }, config);

    this.callParent([config]);
  }
});