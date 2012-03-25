Ext.define('Compass.ErpApp.Mobile.AccomodationUnitSearchResult',{
  extend:'Ext.data.Model',
  config:{
    fields:[
      {name: 'image_url', type:'string'},
      {name: 'description', type:'string'},
      {name: 'number_available', type:'int'},
      {name: 'price', type:'string'},
      {name: 'check_in_date', type:'date', dateFormat:'Y-m-d'},
      {name: 'check_out_date', type:'date', dateFormat:'Y-m-d'},
      {name: 'nights', type:'int'},
      {name: 'unit_type_id', type:'int'}
    ]
  }
});

