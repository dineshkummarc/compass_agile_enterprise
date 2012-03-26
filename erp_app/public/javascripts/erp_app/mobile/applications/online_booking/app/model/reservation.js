Ext.define('Compass.ErpApp.Mobile.OnlineBooking.Reservation',{
  extend:'Ext.data.Model',
  config:{
    fields:[
      {name: 'id', type:'int'},
      {name: 'display_price', type:'string'},
      {name: 'first_name', type:'string'},
      {name: 'last_name', type:'string'},
      {name: 'address_line_1', type:'string'},
      {name: 'address_line_2', type:'string'},
      {name: 'country', type:'string'},
      {name: 'state', type:'string'},
      {name: 'city', type:'string'},
      {name: 'zipcode', type:'string'},
      {name: 'email', type:'string'},
      {name: 'phone', type:'string'},
      {name: 'confirmation_number', type:'string'},
      {name: 'accomodation_unit_type_id', type:'int'},
      {name: 'travel_from_date', type:'date', dateFormat:'Y-m-d'},
      {name: 'travel_to_date', type:'date', dateFormat:'Y-m-d'}
    ],
    validations:[
      {type:'presence', name:'first_name', message:'Enter First Name'},
      {type:'presence', name:'last_name', message:'Enter Last Name'},
      {type:'presence', name:'address_line_1', message:'Enter Address Line 1'},
      {type:'presence', name:'country', message:'Enter Country'},
      {type:'presence', name:'state', message:'Enter State'},
      {type:'presence', name:'city', message:'Enter City'},
      {type:'presence', name:'zipcode', message:'Enter Postal Code'},
      {type:'presence', name:'email', message:'Enter Email Address'},
      {type:'presence', name:'phone', message:'Enter Phone Number'}
    ],
    associations:[
      {type:'hasOne', model:'Compass.ErpApp.Mobile.OnlineBooking.AccomodationUnitType', foreignKey:'accomodation_unit_type_id', name:'accomodationUnitType'}
    ],
    proxy: {
      type: 'ajax',
      url:'/erp_app/mobile/online_booking/reservations',
      reader:{
        rootProperty:'reservations',
        type:'json'
      }
    }
  }
});

