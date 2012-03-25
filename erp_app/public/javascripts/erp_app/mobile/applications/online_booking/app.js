Ext.ns('Compass.ErpApp.Mobile.OnlineBooking');

Compass.ErpApp.Mobile.OnlineBooking.searchResultTemplate = new Ext.XTemplate(
  '<div class="x-docking-horizontal">',
  '<div class="x-img" style="background-image:url({image_url});"></div>',
  '<div class="x-body">',
  '<span class="label">Price</span><span class="value">{price}</span>',
  '&nbsp;&nbsp;<span class="label"># Available</span><span class="value">{number_available}</span>',
  '<br/>',
  '<span class="label">Travel From Date</span><span class="value">{check_in_date:date("m/d/Y")}</span> - <span class="label">Travel To Date</span><span class="value">{check_out_date:date("m/d/Y")}</span>',
  '<br/><br/>',
  '<span>{description}</span>',
  '</div>',
  '</div>'
  );

Ext.application({
  name: 'onlineBooking',
  useLoadMask: true,

  launch: function () {
    var travelToDate = new Date();
    travelToDate.setDate(new Date().getDate()+7);
    
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
            window.location = '/erp_app/mobile'
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
          {
            xtype:'button',
            text:'Search Inventory',
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
              model:'Compass.ErpApp.Mobile.AccomodationUnitSearchResult'
            },
            listeners:{
              itemdoubletap:function(view, index, target, record, e, eOpts){
                var resultsCarousel = view.up('carousel');
                var bookForm = resultsCarousel.query('onlinebooking-bookpanel')[0];
                if(!Ext.isEmpty(bookForm)){
                  resultsCarousel.remove(bookForm, true);
                }

                var onlineBookingPanel = Ext.create('widget.onlinebooking-bookpanel',{
                  reservationData:record.getData()
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
        }]
        }
      ]
    });
  }
});