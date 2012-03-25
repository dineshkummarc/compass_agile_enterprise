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
          xtype:'fieldset',
          title:'Travler Info',
          instructions:'Please into travler information',
          defaults:{
            xtype:'textfield'
          },
          items:[
          {
            label:'First Name',
            name:'first_name'
          },
          {
            label:'Last Name',
            name:'last_name'
          },
          {
            label:'Address line 1',
            name:'address_line_1'
          },
          {
            label:'Address line 2',
            name:'address_line_2'
          },
          {
            label:'Country',
            name:'country'
          },
          {
            label:'State',
            name:'state'
          },
          {
            label:'City',
            name:'city'
          },
          {
            label:'Postal Code',
            name:'zipcode'
          },
          {
            label:'Email Address',
            name:'email'
          },
          {
            label:'Phone Number',
            name:'phone'
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
            xtype:'numberfield'
          },
          {
            label:'Expiration Month',
            name:'credit_card',
            xtype:'numberfield'
          },
          {
            label:'Expiration Year',
            name:'credit_card',
            xtype:'numberfield'
          },
          {
            label:'CVV / CVVS',
            name:'credit_card',
            xtype:'numberfield'
          }
          ]
        },
        {
          xtype:'button',
          text:'Book Reservation',
          flex:1,
          scope:this,
          ui:'round',
          style:'margin:0.1em',
          handler:function(btn){
            var form = btn.up('formpanel');
            form.setMasked({
              xtype:'loadmask',
              message:'Searching for available rooms...'
            });
            btn.up('formpanel').submit({
              url:'/erp_app/mobile/online_booking/search',
              method:'POST',
              success:function(form, result){
                form.setMasked(false);
                var resultsCarousel = btn.up('#outerContainer').query('#resultsCarousel')[0];
                var roomList = resultsCarousel.query('#roomList')[0];
                roomList.getStore().setData(result.packages);
                resultsCarousel.setActiveItem(roomList);
              }
            });
          }
        }
        ]
      }
      ]
    },config);

    this.callParent([config]);
  }
});
