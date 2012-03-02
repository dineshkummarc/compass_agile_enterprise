/**
 * UserInfo
 */
Ext.define("Compass.ErpApp.Organizer.Applications.Crm.UserInfo",{
  extend:"Ext.panel.Panel",
  alias:'widget.userinfo',

  initComponent: function () {
    var config = this.initialConfig;
    var self = this;

    this.setParams = function(params) {
      this.partyId = params.partyId;
      this.store.proxy.extraParams.party_id = params.partyId;
    };
    
    var store = Ext.create('Ext.data.Store', {
      proxy: {
        type: 'ajax',
        url : '/erp_app/organizer/crm/get_user',
        reader: {
          type: 'json',
          root: 'data'
        }
      },
      fields:[
      {
        name: 'id',
        type: 'int'
      },
      {
        name: 'username',
        type: 'string'
      },
      {
        name: 'email',
        type: 'string'
      },
      {
        name: 'activation_state',
        type: 'string'
      },
      {
        name: 'last_login_at',
        type: 'string'
      },
      {
        name: 'failed_logins_count',
        type: 'string'
      },
      {
        name: 'activation_token',
        type: 'string'
      }],
      listeners:{
        'load':function(store){
            rec = store.getAt(0);
            if (rec){
              Ext.getCmp('editUserForm_'+this.partyId).getForm().loadRecord(rec);
            }
        }
      }      
    });

    this.store = store;

    this.callParent(arguments);
  },

  constructor: function(config) {
    var self = this;

    var actions = Ext.create('Ext.form.Panel',{
      title: 'Actions',
      region: 'north',
      buttonAlign: 'left',
      buttons: [{
        text:'Activate User',
        width: 125,
        listeners:{
          'click':function(button){
            actions.getForm().submit({
              url:'/erp_app/organizer/crm/activate/',
              params:{
                party_id: self.partyId,
                activation_token: self.store.getAt(0).data.activation_token
              },
              waitMsg:'Activating User',
              success:function(form, action){
                var response =  Ext.decode(action.response.responseText);
                Ext.Msg.alert("Status", response.message);
              },
              failure:function(form, action){
                var message = 'Error activating user';
                if(action.response != null){
                  var response =  Ext.decode(action.response.responseText);
                  message = response.message;
                }
                Ext.Msg.alert("Status", message);
              }
            });
          }
        }
      },
      {
        text:'Reset Password',
        width: 125,
        listeners:{
          'click':function(button){
            actions.getForm().submit({
              url:'/users/reset_password/',
              params:{
                party_id: self.partyId,
                login: self.store.getAt(0).data.username
              },
              waitMsg:'Resetting Password',
              success:function(form, action){
                var response =  Ext.decode(action.response.responseText);
                Ext.Msg.alert("Status", response.message);
              },
              failure:function(form, action){
                var message = 'Error resetting password';
                if(action.response != null){
                  var response =  Ext.decode(action.response.responseText);
                  message = response.message;
                }
                Ext.Msg.alert("Status", message);
              }
            });
          }
        }
      }]
    });

    var edit_user = Ext.create('Ext.form.Panel',{
      title: 'Edit User',
      region: 'center',
      id: 'editUserForm_'+self.partyId,
      height: 100,
      buttonAlign: 'left',
      labelWidth: 110,
      frame:false,
      bodyStyle:'padding:5px 5px 0',
      width: 425,
      url:'/erp_app/organizer/crm/update_user',
      defaults: {
        width: 300
      },
      items: [{
        xtype:'textfield',
        fieldLabel:'Username',
        allowBlank:false,
        name:'username'
      },
      {
        xtype:'textfield',
        fieldLabel:'Email Address',
        allowBlank:false,
        name:'email',
        vtype: 'email'
      },
      {
        xtype:'displayfield',
        fieldLabel:'Activation State',
        name:'activation_state'
      },
      {
        xtype:'displayfield',
        fieldLabel:'Last Login At',
        name:'last_login_at'
      },
      {
        xtype:'displayfield',
        fieldLabel:'Failed Logins',
        name:'failed_logins_count'
      }
      ],
      buttons: [{
        text:'Save',
        listeners:{
          'click':function(button){
            edit_user.getForm().submit({
              params:{
                party_id: self.partyId
              },
              waitMsg:'Updating User',
              success:function(form, action){
                var response =  Ext.decode(action.response.responseText);
                Ext.Msg.alert("Status", response.message);
              },
              failure:function(form, action){
                var message = 'Error resetting password';
                if(action.response != null){
                  var response =  Ext.decode(action.response.responseText);
                  message = response.message;
                }
                Ext.Msg.alert("Status", message);
              }
            });
          }
        }
      }]
    });

    config = Ext.apply({
            title: 'User Info',
            id: 'user_'+self.partyId,
            layout:'border',
            split: true,
            items:[actions, edit_user]
        }, config);

    this.callParent([config]);
  }
});