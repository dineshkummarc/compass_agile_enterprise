Ext.define('Compass.ErpApp.Mobile.UserManagement.Store.Users', {
  extend: 'Ext.data.Store',
  config: {
    grouper:function(record){
      return record.get('username')[0];
    },
    model: 'Compass.ErpApp.Mobile.UserManagement.User',
    proxy:{
      autoLoad: true,
      url:'/erp_app/mobile/user_management/users',
      type:'ajax',
      reader:{
        type:'json',
        rootProperty:'users'
      }
    }
  }
});

