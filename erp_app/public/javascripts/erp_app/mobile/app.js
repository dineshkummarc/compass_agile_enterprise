Compass.ErpApp.Mobile.Applications = {};
Compass.ErpApp.Mobile.Base = {};

Ext.application({
  name: 'compass_ae_mobile',
  useLoadMask: true,

  launch: function () {
    Ext.create("Ext.tab.Panel", {
      fullscreen: true,
      tabBarPosition: 'bottom',

      items: [
      {
        title: 'Home',
        iconCls: 'home',
        html: [
        '<img src="/images/art/',
        Compass.ErpApp.Mobile.CompassLogo,
        '" />',
        '<h1>Welcome to CompassAE Mobile</h1>',
        "<p>Here you can access your CompassAE applications on the go.</p>",
        ].join("")
      },
      {
        xtype: 'container',
        title: 'Applications',
        iconCls: 'star',
        layout:{
          type:'vbox',
          align:'strech'
        },
        defaults:{
          xtype:'container',
          layout:{
            type:'hbox',
            align:'middle'
          },
          defaults:{
            xtype:'button',
            flex:1,
            margin:10
          }
        },
        items:[
        {
          items:[

          {
            text:'User Management',
            iconCls:'icon-user',
            ui:'round',
            handler:function(){
              window.location = "/erp_app/mobile/user_management"
            }
          },
          {
            text:'Online Booking',
            iconCls:'icon-house',
            ui:'round',
            handler:function(){
              window.location = "/erp_app/mobile/online_booking"
            }
          }
          ]
        }
        ]
      }
      
      ]
    });
  }
});