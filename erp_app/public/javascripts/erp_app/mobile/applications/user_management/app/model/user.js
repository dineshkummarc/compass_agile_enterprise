Ext.define('Compass.ErpApp.Mobile.UserManagement.User',{
  extend:'Ext.data.Model',
  config:{
    fields:[
      {name: 'username', type:'string'},
      {name: 'last_activity_at', type:'date', dateFormat:'Y-m-dTg:i:s'},
      {name: 'last_login_at', type:'date', dateFormat:'Y-m-dTg:i:s'},
      {name: 'email', type:'string'},
      {name: 'failed_logins_count', type:'int'},
      {name: 'activation_state', type:'string'}
    ]
  }
});

