Ext.application({
  name: 'compass_ae_mobile_login',
  useLoadMask: true,

  launch: function () {
    Ext.create("Ext.form.Panel", {
      fullscreen: true,
      defaults:{
        xtype:'textfield'
      },
      items: [
      {
        label:'Username or Email Address',
        name:'login',
        required:true
      },
      {
        xtype:'passwordfield',
        label:'Password',
        name:'password',
        required:true
      },
      {
        xtype:'button',
        text:'Login',
        flex:1,
        scope:this,
        ui:'confirm-round',
        style:'margin:0.1em',
        handler:function(btn){
          var form = btn.up('formpanel');
          form.setMasked({
            xtype:'loadmask',
            message:'Authenticating User...'
          });
          form.submit({
            url:'/session/sign_in',
            method:'POST',
            success:function(form, result){
              form.setMasked(false);
              window.location = Compass.ErpApp.Mobile.LoginTo;
            },
            failure:function(form, result){
              Ext.Msg.alert("Error", "Could not authenticate .");
            }
          });
        }
      }
      ]
    });
  }
});