Compass.ErpApp.Widgets.Login = {
  addLogin:function(){
    var addLoginWidgetWindow = Ext.create("Ext.window.Window",{
      layout:'fit',
      width:375,
      title:'Add Login Widget',
      plain: true,
      buttonAlign:'center',
      items: Ext.create("Ext.form.Panel",{
        labelWidth: 100,
        frame:false,
        bodyStyle:'padding:5px 5px 0',
        defaults: {
          width: 225
        },
        items: [
        {
          xtype: 'combo',
          forceSelection:true,
          store: [
          [':login_header','Header'],
          [':login_page','Page'],
          ],
          fieldLabel: 'Widget View',
          value:':login_page',
          name: 'widgetLayout',
          allowBlank: false,
          triggerAction: 'all',
          listeners:{
            change:function(field, newValue, oldValue){
              var basicForm = field.findParentByType('form').getForm();
              var loginWidgetLoginToField = basicForm.findField('loginWidgetLoginTo');
              var loginWidgetLogoutToField = basicForm.findField('loginWidgetLogoutTo');
              var loginWidgetLoginUrlField = basicForm.findField('loginWidgetLoginUrl');
              var loginWidgetSignUpUrlField = basicForm.findField('loginWidgetSignUpUrl');
              var loginWidgetResetPasswordUrlField = basicForm.findField('loginWidgetResetPasswordUrl');
              if(newValue == ':login_header'){
                loginWidgetLoginToField.hide();
                loginWidgetLogoutToField.hide();
                loginWidgetLoginUrlField.show();
                loginWidgetResetPasswordUrlField.hide();
                loginWidgetLoginUrlField.setValue('/login');
                loginWidgetSignUpUrlField.setValue('/sign-up');
                loginWidgetResetPasswordUrlField.setValue('/reset-password');
              }
              else{
                loginWidgetLoginToField.show();
                loginWidgetLogoutToField.show();
                loginWidgetLoginUrlField.hide();
                loginWidgetResetPasswordUrlField.show();
                loginWidgetLoginToField.setValue('/home');
                loginWidgetLogoutToField.setValue('/home');
                loginWidgetSignUpUrlField.setValue('/sign-up');
              }
            }
          }
        },
        {
          xtype:'textfield',
          fieldLabel:'Login To',
          allowBlank:false,
          value:'/home',
          id:'loginWidgetLoginTo'
        },
        {
          xtype:'textfield',
          fieldLabel:'Logout To',
          allowBlank:false,
          value:'/home',
          id:'loginWidgetLogoutTo'
        },
        {
          xtype:'textfield',
          fieldLabel:'Login Url',
          allowBlank:false,
          hidden:true,
          value:'/login',
          id:'loginWidgetLoginUrl'
        },
        {
          xtype:'textfield',
          toolTip:'Only needed if Signup widget is setup.',
          fieldLabel:'Sign Up Url',
          allowBlank:true,
          value:'/sign-up',
          id:'loginWidgetSignUpUrl'
        },
        {
          xtype:'textfield',
          toolTip:'Only needed if Reset Password widget is setup.',
          fieldLabel:'Reset Password Url',
          allowBlank:true,
          hidden:true,
          value:'/reset-password',
          id:'loginWidgetResetPasswordUrl'
        }
        ]
      }),
      buttons: [{
        text:'Submit',
        listeners:{
          'click':function(button){
            var tpl = null;
            var content = null;
            var window = button.findParentByType('window');
            var formPanel = window.query('form')[0];
            var basicForm = formPanel.getForm();
            var action = basicForm.findField('widgetLayout').getValue();

            var loginWidgetSignUpUrlField = basicForm.findField('loginWidgetSignUpUrl');
            var loginWidgetResetPasswordUrlField = basicForm.findField('loginWidgetResetPasswordUrl');
            var data = {
              action:action
            };
            data.loginWidgetSignUpUrl = loginWidgetSignUpUrlField.getValue();
            data.loginWidgetResetPasswordUrl = loginWidgetResetPasswordUrlField.getValue();
            if(action == ':login_header'){
              var loginWidgetLoginUrlField = basicForm.findField('loginWidgetLoginUrl');
              data.loginWidgetLoginUrl = loginWidgetLoginUrlField.getValue();
              tpl = new Ext.XTemplate("<%= render_widget :login,\n",
                "   :action => :login_header,\n",
                "   :params => {:login_url => '{loginWidgetLoginUrl}',\n",
                "               :signup_url => '{loginWidgetSignUpUrl}'}%>");
              content = tpl.apply(data);
            }
            else{
              var loginWidgetLoginToField = basicForm.findField('loginWidgetLoginTo');
              var loginWidgetLogoutToField = basicForm.findField('loginWidgetLogoutTo');
              data.loginWidgetLoginTo = loginWidgetLoginToField.getValue();
              data.loginWidgetLogoutTo = loginWidgetLogoutToField.getValue();
              tpl = new Ext.XTemplate("<%= render_widget :login,\n",
                "   :params => {:login_to => '{loginWidgetLoginTo}',\n",
                "               :logout_to => '{loginWidgetLogoutTo}',\n",
                "               #optional field if Sign Up widget is setup\n",
                "               #:signup_url => '{loginWidgetSignUpUrl}',\n",
                "               #optional field if Reset Password widget is setup\n",
                "               #:reset_password_url => '{loginWidgetResetPasswordUrl}'}%>");
              content = tpl.apply(data);
            }

            //add rendered template to center region editor
            Ext.getCmp('knitkitCenterRegion').addContentToActiveCodeMirror(content);
            addLoginWidgetWindow.close();
          }
        }
      },{
        text: 'Close',
        handler: function(){
          addLoginWidgetWindow.close();
        }
      }]
    });
    addLoginWidgetWindow.show();
  }
}

Compass.ErpApp.Widgets.AvailableWidgets.push({
  name:'Login',
  iconUrl:'/images/icons/key/key_48x48.png',
  onClick:Compass.ErpApp.Widgets.Login.addLogin,
  about:'This widget creates a login form to allow users to log into the website.'
});


