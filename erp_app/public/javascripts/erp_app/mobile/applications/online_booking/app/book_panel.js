Ext.define('Compass.ErpApp.Mobile.OnlineBooking.BookPanel',{
  extend:'Ext.Container',
  alias:'widget.onlinebooking-bookpanel',

  constructor:function(config){

    config = Ext.apply({
      layout:'vbox',
      items:[
      {
        tpl:Compass.ErpApp.Mobile.OnlineBooking.searchResultTemplate,
        data:config.reservationData,
        flex:0.5
      },
      {
        xtype:'formpanel',
        flex:2,
        items:[
        {
          xtype:'hiddenfield',
          name:'unit_type_id',
          value:config.reservationData.unit_type_id
        },
        {
          xtype:'hiddenfield',
          name:'check_in_date',
          value:config.reservationData.check_in_date
        },
        {
          xtype:'hiddenfield',
          name:'check_out_date',
          value:config.reservationData.check_out_date
        },
        {
          xtype:'hiddenfield',
          name:'price',
          value:config.reservationData.price
        },
        {
          xtype:'hiddenfield',
          name:'nights',
          value:config.reservationData.nights
        },
        {
          xtype:'fieldset',
          title:'Travler Info',
          instructions:'Please into travler information',
          defaults:{
            xtype:'textfield'
          },
          items:[
          {
            label:'First Name',
            name:'first_name',
            required:true
          },
          {
            label:'Last Name',
            name:'last_name',
            required:true
          },
          {
            label:'Address line 1',
            name:'address_line_1',
            required:true
          },
          {
            label:'Address line 2',
            name:'address_line_2',
            required:true
          },
          {
            label:'Country',
            name:'country',
            xtype:'selectfield',
            valueField:'value',
            displayField:'description',
            value:'US',
            store:'onlinebooking-countriesstore',
            required:true
          },
          {
            label:'State',
            name:'state',
            xtype:'selectfield',
            valueField:'value',
            displayField:'description',
            value:'FL',
            store:'onlinebooking-statesstore',
            required:true
          },
          {
            label:'City',
            name:'city',
            required:true
          },
          {
            label:'Postal Code',
            name:'zipcode',
            required:true
          },
          {
            label:'Email Address',
            xtype:'emailfield',
            name:'email',
            required:true
          },
          {
            label:'Phone Number',
            name:'phone',
            required:true
          }
          ]
        },
        {
          xtype:'fieldset',
          title:'Credit Card',
          instructions:'Please into credit card information',
          defaults:{
            xtype:'textfield'
          },
          items:[
          {
            label:'Credit Card Number',
            xtype:'numberfield',
            name:'credit_card'
          },
          {
            label:'Expiration Month',
            name:'credit_card_ex_month',
            xtype:'numberfield'
          },
          {
            label:'Expiration Year',
            name:'credit_card_ex_year',
            xtype:'numberfield'
          },
          {
            label:'CVV / CVVS',
            name:'cvv',
            xtype:'numberfield'
          }
          ]
        },
        {
          xtype:'button',
          text:'Book Reservation',
          flex:1,
          scope:this,
          ui:'confirm-round',
          style:'margin:0.1em',
          handler:function(btn){
            var form = btn.up('formpanel');
            var reservation = Ext.create('Compass.ErpApp.Mobile.OnlineBooking.Reservation',form.getValues());
            var errors = reservation.validate(),message="";
            if(errors.isValid()){
              form.setMasked({
                xtype:'loadmask',
                message:'Booking reservation...'
              });
              form.submit({
                url:'/erp_app/mobile/online_booking/submit',
                method:'POST',
                success:function(form, result){
                  form.setMasked(false);
                  var resultsCarousel = btn.up('#searchContainer').query('#resultsCarousel')[0];
                  var bookPanel = resultsCarousel.query('#bookPanel')[0];
                  if(!Ext.isEmpty(bookPanel)){
                    resultsCarousel.remove(bookPanel, true);
                  }
                  var resultsPanel = Ext.create('Ext.Container',{
                    layout:'fit',
                    itemId:'bookPanel',
                    html:result.html
                  });
                  resultsCarousel.add(resultsPanel);
                  resultsCarousel.setActiveItem(resultsPanel);
                },
                failure:function(form, result){
                  Ext.Msg.alert("Error", "There was an error booking the reservation.");
                }
              });
            }
            else{
              Ext.each(errors.items, function(rec,i){
                message += rec._message+"<br/>";
              });
              Ext.Msg.alert("Please address the following.", message, function(){});
              return false;
            }
          }
        }
        ]
      }
      ]
    },config);

    this.callParent([config]);
  }
});
