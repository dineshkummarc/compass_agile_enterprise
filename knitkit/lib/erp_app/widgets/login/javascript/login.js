Compass.ErpApp.Widgets.Login = {
    addLogin:function(){
        var addLoginWidgetWindow = Ext.create("Ext.window.Window",{
            layout:'fit',
            width:375,
            title:'Add Login Widget',
            height:190,
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
                    width: 150,
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
                            if(newValue == ':login_header'){
                                loginWidgetLoginToField.hide();
                                loginWidgetLogoutToField.hide();
                                loginWidgetLoginUrlField.show();
                                loginWidgetLoginUrlField.setValue('/login');
                                loginWidgetSignUpUrlField.setValue('/sign-up');
                            }
                            else{
                                loginWidgetLoginToField.show();
                                loginWidgetLogoutToField.show();
                                loginWidgetLoginUrlField.hide();
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
                    fieldLabel:'Sign Up Url',
                    allowBlank:false,
                    value:'/sign-up',
                    id:'loginWidgetSignUpUrl'
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
                        var data = {action:action};
                        data.loginWidgetSignUpUrl = loginWidgetSignUpUrlField.getValue();
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
                                                    "               :signup_url => '{loginWidgetSignUpUrl}'}%>");
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
    onClick:Compass.ErpApp.Widgets.Login.addLogin
});


