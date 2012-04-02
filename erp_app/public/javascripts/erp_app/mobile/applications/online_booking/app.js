Ext.ns('Compass.ErpApp.Mobile.OnlineBooking');

Ext.application({
  name: 'onlineBooking',
  useLoadMask: true,

  launch: function () {
    var travelToDate = new Date();
    travelToDate.setDate(new Date().getDate()+7);
    
    //stores
    Ext.create('Compass.ErpApp.Mobile.OnlineBooking.Store.States',{
      storeId:'onlinebooking-statesstore'
    }).load();
    Ext.create('Compass.ErpApp.Mobile.OnlineBooking.Store.Countries',{
      storeId:'onlinebooking-countriesstore'
    }).load();

    Ext.create("Ext.tab.Panel", {
      activeItem:0,
      fullscreen: true,
      tabBarPosition: 'bottom',
      items: [
      {
        xtype:'toolbar',
        ui:'light',
        docked:'top',
        items:[
        {
          text:'Home',
          ui:'back',
          handler:function(btn){
            window.location = '/erp_app/mobile';
          }
        },
        {
          text:'Logout',
          ui:'round',
          handler:function(btn){
            window.location = '/session/sign_out?login_url=/erp_app/mobile/login';
          }
        }
        ]
      },
      {
        xtype:'container',
        layout:'vbox',
        itemId:'searchContainer',
        title: 'Search',
        iconCls: 'search',
        items:[
        {
          xtype:'formpanel',
          flex:0.55,
          items:[
          {
            label:'Travel From Date',
            xtype:'datepickerfield',
            destroyPickerOnHide:true,
            value:new Date(),
            picker:{
              yearTo:2016
            },
            name:'check_in_date'
          },
          {
            label:'Travel To Date',
            xtype:'datepickerfield',
            destroyPickerOnHide:true,
            value:travelToDate,
            picker:{
              yearTo:2016
            },
            name:'check_out_date'
          },
          Compass.ErpApp.Mobile.AuthentictyTokenField,
          {
            xtype:'button',
            text:'Search Inventory',
            flex:1,
            scope:this,
            ui:'confirm-round',
            style:'margin:0.1em',
            handler:function(btn){
              var form = btn.up('formpanel');
              form.setMasked({
                xtype:'loadmask',
                message:'Searching for available rooms...'
              });
              form.submit({
                url:'/erp_app/mobile/online_booking/search',
                method:'POST',
                success:function(form, result){
                  form.setMasked(false);
                  var resultsCarousel = btn.up('#searchContainer').query('#resultsCarousel')[0];
                  var roomList = resultsCarousel.query('#roomList')[0];
                  roomList.getStore().setData(result.packages);
                  resultsCarousel.setActiveItem(roomList);
                }
              });
            }
          }
          ]
        },
        {
          xtype:'carousel',
          itemId:'resultsCarousel',
          activeItem:0,
          flex:2,
          items:[
          {
            xtype:'list',
            itemId:'roomList',
            ui:'round',
            itemTpl:Compass.ErpApp.Mobile.OnlineBooking.searchResultTemplate,
            store:{
              model:'Compass.ErpApp.Mobile.OnlineBooking.AccomodationUnitSearchResult'
            },
            listeners:{
              itemdoubletap:function(view, index, target, record, e, eOpts){
                e.stopEvent();
                var resultsCarousel = view.up('carousel');
                var bookPanel = resultsCarousel.query('#bookPanel')[0];
                if(!Ext.isEmpty(bookPanel)){
                  resultsCarousel.remove(bookPanel, true);
                }
                var onlineBookingPanel = Ext.create('widget.onlinebooking-bookpanel',{
                  reservationData:record.getData(),
                  itemId:'bookPanel'
                });
                resultsCarousel.add(onlineBookingPanel);
                resultsCarousel.setActiveItem(onlineBookingPanel);
              }
            }
          }
          ]
        }
        ]
      },
      {
        xtype:'container',
        layout:'vbox',
        itemId:'reservationsContainer',
        title: 'Reservations',
        iconCls: 'bookmarks',
        items:[
        {
          xtype:'formpanel',
          flex:0.55,
          items:[
          Compass.ErpApp.Mobile.AuthentictyTokenField,
          {
            label:'Confirmation #',
            xtype:'textfield',
            name:'confirmation_number'
          },
          {
            xtype:'button',
            text:'Find Reservation',
            flex:1,
            scope:this,
            ui:'confirm-round',
            style:'margin:0.1em',
            handler:function(btn){
              var form = btn.up('formpanel');
              var reservation = Ext.ModelManager.getModel('Compass.ErpApp.Mobile.OnlineBooking.Reservation');
              form.setMasked({
                xtype:'loadmask',
                message:'Searching for reservation...'
              });
              reservation.load(form.getValues().confirmation_number,{
                success:function(reservation){
                  var confirmationSearchResult = btn.up('#reservationsContainer').query('#confirmationSearchResult').first();
                  if(Ext.isEmpty(reservation)){
                    confirmationSearchResult.setHtml(Compass.ErpApp.Mobile.OnlineBooking.emptyResults.apply());
                  }
                  else{
                    reservation.getAccomodationUnitType({
                      success:function(args){
                        form.setMasked(false);
                        
                        //remove mapit if its there
                        var mapItPanel = confirmationSearchResult.query('#mapItPanel').first();
                        if(!Ext.isEmpty(mapItPanel)){
                          confirmationSearchResult.remove(mapItPanel,true);
                        }

                        //remove summary if its there
                        var confirmationSummary = confirmationSearchResult.query('#confirmationSummary').first();
                        if(!Ext.isEmpty(confirmationSummary)){
                          confirmationSearchResult.remove(confirmationSummary,true);
                        }

                        confirmationSearchResult.add({
                          xtype:'container',
                          layout:'hbox',
                          itemId:'confirmationSummary',
                          items:[
                          {
                            xtype:'container',
                            layout:'fit',
                            flex:1,
                            itemId:'confirmationRoomInfo'
                          },
                          {
                            xtype:'container',
                            layout:'fit',
                            flex:2,
                            itemId:'confirmationTravelerInfo'
                          }
                          ]
                        });
                        var unitType = args[0];
                        var roomData = {
                          accomodationUnitTypeUrl:unitType.data.img_url,
                          accomodationUnitTypeDescription:unitType.data.description,
                          accomodationUnitTypeLongDescription:unitType.data.long_description,
                          display_price:reservation.data.display_price,
                          confirmation_number:reservation.data.confirmation_number,
                          travel_to_date:reservation.data.travel_to_date,
                          travel_from_date:reservation.data.travel_from_date
                        }
                        var roomInfo = confirmationSearchResult.query('#confirmationRoomInfo').first();
                        roomInfo.setHtml(Compass.ErpApp.Mobile.OnlineBooking.reservationConfirmationRoomInfo.apply(roomData));

                        var travelerInfo = confirmationSearchResult.query('#confirmationTravelerInfo').first();
                        travelerInfo.setHtml(Compass.ErpApp.Mobile.OnlineBooking.reservationConfirmationTravelerInfo.apply(reservation.data));

                        Ext.create('Ext.Button',{
                          renderTo:'emailConfirmationBtnHolder',
                          text:'Email Confirmation',
                          flex:0.5,
                          handler:function(btn){
                            confirmationSearchResult.setMasked({
                              xtype:'loadmask',
                              message:'Emailing confirmation...'
                            });
                            Ext.Ajax.request({
                              url:'/erp_app/mobile/online_booking/email_confirmation',
                              params:{
                                confirmation_number:reservation.data.confirmation_number
                              },
                              success:function(response, opts){
                                confirmationSearchResult.setMasked(false);
                                var obj = Ext.decode(response.responseText);
                                if(obj.success){
                                  Ext.Msg.alert("Success", "Confirmation email has been sent.");
                                }
                              },
                              failure:function(response, opts){
                                btn.up('#confirmationSearchResult').setMasked(false);
                                Ext.Msg.alert("Error", "Error sending confirmation email.");
                              }
                            });
                          }
                        });

                        Ext.create('Ext.Button',{
                          renderTo:'mapItBtnHolder',
                          text:'Map It',
                          flex:0.5,
                          handler:function(btn){
                            var mapItPanel = confirmationSearchResult.query('#mapItPanel').first();
                            if(!Ext.isEmpty(mapItPanel)){
                              confirmationSearchResult.remove(mapItPanel,true);
                            }

                            mapItPanel = Ext.create('Ext.Map',{itemId:'mapItPanel'});
                            var map = mapItPanel.getMap();
                            var geocoder = new google.maps.Geocoder();
                            geocoder.geocode( {'address': '2301 Ridge Road Pigeon Forge TN 37863'}, function(results, status) {
                              if (status == google.maps.GeocoderStatus.OK) {
                                map.setCenter(results[0].geometry.location);
                                new google.maps.Marker({
                                  map: map,
                                  animation: google.maps.Animation.DROP,
                                  position: results[0].geometry.location,
                                  title:'Resort'
                                });
                              } else {
                                alert("Geocode was not successful for the following reason: " + status);
                              }
                            });

                            confirmationSearchResult.add(mapItPanel);
                            confirmationSearchResult.setActiveItem(mapItPanel);
                          }
                        });
                      },
                      failure:function(){
                        Ext.Msg.alert("Error", "Error searching for your reservation.");
                      }
                    });
                  }
                },
                failure:function(){
                  form.setMasked(false);
                  Ext.Msg.alert("Error", "Error searching for your reservation.");
                }
              })
            }
          }
          ]
        },
        {
          xtype:'carousel',
          itemId:'confirmationSearchResult',
          flex:2
        }]
      }
      ]
    });
  }
});