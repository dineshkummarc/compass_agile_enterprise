Ext.define('Compass.ErpApp.Mobile.OnlineBooking.AccomodationUnitType',{
  extend:'Ext.data.Model',
  config:{
    fields:[
      {name: 'id', type:'int'},
      {name: 'description', type:'string'},
      {name: 'long_description', type:'string'},
      {name: 'img_url', type:'string'},
      {name: 'internal_identifier', type:'string'}
    ],
    proxy: {
      type: 'ajax',
      url:'/erp_app/mobile/online_booking/accomodation_unit_types',
      reader:{
        rootProperty:'accomodation_unit_types',
        type:'json'
      }
    }
  }
});

