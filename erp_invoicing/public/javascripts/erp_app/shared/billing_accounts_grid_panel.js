Ext.define('Compass.ErpApp.Shared.BillingAccount',{
  extend:'Ext.data.Model',
  fields:[{
    name:'id'
  },{
    name:'account_number'
  },{
    name:'calculate_balance'
  },{
    name:'payment_due'
  },{
    name:'balance'
  },{
    name:'due_date'
  },{
    name:'balance_date'
  },{
    name:'payable_online'
  },{
    name:'send_paper_bills'
  }],
  validations:[
  {
    type:'presence',
    field: 'account_number'
  },
  {
    type:'presence',
    field: 'balance'
  },
  {
    type:'presence',
    field: 'payment_due'
  }
  ]
});

Ext.define("Compass.ErpApp.Shared.BillingAccountsGridPanel",{
  extend:"Ext.grid.Panel",
  alias:'widget.shared-billingaccountsgridpanel',
  title:'Billing Accounts',
  addDocument : function(rec){
    var uploadWindow = new Compass.ErpApp.Shared.UploadWindow({
      standardUploadUrl:'/erp_invoicing/erp_app/shared/billing_accounts/'+rec.get('id')+'/upload_file',
      flashUploadUrl:'/erp_invoicing/erp_app/shared/billing_accounts/'+rec.get('id')+'/upload_file',
      xhrUploadUrl:'/erp_invoicing/erp_app/shared/billing_accounts/'+rec.get('id')+'/upload_file',
      extraPostData:{}
    });
    uploadWindow.show();
  },

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
      autoLoad: Compass.ErpApp.Utility.isBlank(config['autoLoad']) ? true : config['autoLoad'],
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

    var editingPlugin = Ext.create('Ext.grid.plugin.RowEditing', {
      clicksToMoveEditor: 1
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
          var grid = button.up('shared-billingaccountsgridpanel');
          grid.store.insert(0, new Compass.ErpApp.Shared.BillingAccount({
            payment_due:0.00,
            balance:0.00,
            due_date:new Date(),
            balance_date:new Date()
          }));
          editingPlugin.startEdit(0,0);
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
    }

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
      }]);

    config = Ext.apply({
      plugins:[editingPlugin],
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
          var result = ''
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
          var result = ''
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
          var result = ''
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
      })
      
    }, config);

    this.callParent([config]);
  }
});