Ext.define('Compass.ErpApp.Mobile.OnlineBooking.Store.Countries', {
  extend: 'Ext.data.Store',
  config: {
    model: 'Compass.ErpApp.Mobile.OnlineBooking.Country',
    proxy:{
      autoLoad: true,
      url:'/erp_app/mobile/online_booking/countries',
      type:'ajax',
      reader:{
        type:'json',
        rootProperty:'countries'
      }
    }
  }
});

