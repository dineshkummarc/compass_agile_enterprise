Ext.ns('Compass.ErpApp.Mobile.UserManagement');

Ext.application({
  name: 'UserManagement',
  useLoadMask: true,
  launch: function () {
    Ext.create('Compass.ErpApp.Mobile.UserManagement.Store.Users',{
      storeId:'usermanagement-usersstore'
    }).load();
    
    var center = null;
    if(Ext.os.deviceType == 'Phone'){
      center = {
        layout:'card',
        itemId:'userList',
        title: 'Find User',
        iconCls: 'search',
        items:[
        {
          xtype: 'list',
          store: 'usermanagement-usersstore',
          itemTpl: '<div class="contact"><strong>{username}</strong></div>',
          grouped: true,
          indexBar: true,
          listeners:{
            itemdoubletap:function(view, index, target, record, e, eOpts){
              e.stopEvent();
              var userList = view.up('#userList');
              userList.add({
                layout:'fit',
                tpl:Compass.ErpApp.Mobile.UserManagement.Templates.userDetails,
                data:record.getData(),
                items:[{
                  xtype:'toolbar',
                  ui:'light',
                  docked:'top',
                  items:[
                  {
                    text:'Back',
                    ui:'back',
                    handler:function(btn){
                      userList.setActiveItem(userList.items.first());
                      userList.removeAt(1);
                    }
                  }
                  ]
                }]
              });
              userList.setActiveItem(userList.items.last());

              Ext.create('Ext.Button',{
                renderTo:'resetPasswdBtnHolder',
                text:'Reset Password',
                flex:0.5,
                login:record.get('username'),
                handler:function(btn){
                  Ext.Ajax.request({
                    url:'/users/reset_password',
                    params:{
                      login:btn.initialConfig.login,
                      login_to:'/erp_app/mobile/login'
                    },
                    success:function(response, opts){
                      var obj = Ext.decode(response.responseText);
                      if(obj.success){
                        Ext.Msg.alert("Success", "Password reset and email sent.");
                      }
                    },
                    failure:function(response, opts){
                      Ext.Msg.alert("Error", "Error re-setting password.");
                    }
                  });
                }
              });
            }
          }
        }
        ]
      };
    }
    else{
      center = {
        layout:{
          type:'hbox'
        },
        itemId:'userList',
        title: 'Find User',
        iconCls: 'search',
        items:[
        {
          xtype: 'list',
          width: 300,
          height: 500,
          store: 'usermanagement-usersstore',
          itemTpl: '<div class="contact"><strong>{username}</strong></div>',
          grouped: true,
          indexBar: true,
          listeners:{
            itemdoubletap:function(view, index, target, record, e, eOpts){
              e.stopEvent();
              var userList = view.up('#userList');
              userList.query('#userDetails').first().setHtml(Compass.ErpApp.Mobile.UserManagement.Templates.userDetails.apply(record.getData()));
              Ext.create('Ext.Button',{
                renderTo:'resetPasswdBtnHolder',
                text:'Reset Password',
                flex:0.5,
                login:record.get('username'),
                handler:function(btn){
                  Ext.Ajax.request({
                    url:'/users/reset_password',
                    params:{
                      login:btn.initialConfig.login,
                      login_to:'/erp_app/mobile/login'
                    },
                    success:function(response, opts){
                      var obj = Ext.decode(response.responseText);
                      if(obj.success){
                        Ext.Msg.alert("Success", "Password reset and email sent.");
                      }
                    },
                    failure:function(response, opts){
                      Ext.Msg.alert("Error", "Error re-setting password.");
                    }
                  });
                }
              });
            }
          }
        },
        {
          itemId:'userDetails',
          style:'padding:5px;'
        }
        ]
      };
    }

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
      center
      ]
    });
  }
});
