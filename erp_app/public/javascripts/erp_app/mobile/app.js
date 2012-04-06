Ext.application({
  name: 'compass_ae_mobile',
  useLoadMask: true,

  launch: function () {
    Ext.create("Ext.tab.Panel", {
      fullscreen: true,
      tabBarPosition: 'bottom',
      items: [
      {
        xtype:'toolbar',
        ui:'light',
        docked:'top',
        items:[
        {
          text:'Logout',
          ui:'back',
          handler:function(btn){
            window.location = '/session/sign_out?login_url=/erp_app/mobile/login';
          }
        }
        ]
      },
      {
        title: 'Home',
        iconCls: 'home',
        style:'background-image: url("/images/wallpaper/truenorth.png");background-position:center;'
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
          xtype:'button',
          margin:10
        },
        items:mobileApplications
      }
      ]
    });
  }
});