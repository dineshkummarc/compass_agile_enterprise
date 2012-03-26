Ext.define('Compass.ErpApp.Mobile.OnlineBooking.Store.States', {
  extend: 'Ext.data.Store',
  config: {
    model: 'Compass.ErpApp.Mobile.OnlineBooking.State',
    proxy:{
      autoLoad: true,
      url:'/erp_app/mobile/online_booking/states',
      type:'ajax',
      reader:{
        type:'json',
        rootProperty:'states'
      }
    }
  }
});

