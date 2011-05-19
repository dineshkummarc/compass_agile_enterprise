Compass.ErpApp.Widgets.Login = {
    addLogin:function(){
        var addLoginWidgetWindow = new Ext.Window({
            layout:'fit',
            width:375,
            title:'Add Login Widget',
            height:130,
            plain: true,
            buttonAlign:'center',
            items: new Ext.FormPanel({
                labelWidth: 100,
                frame:false,
                bodyStyle:'padding:5px 5px 0',
                defaults: {
                    width: 225
                },
                items: [
                {
                    xtype:'textfield',
                    fieldLabel:'Login To',
                    allowBlank:false,
                    id:'loginWidgetLoginTo'
                },
                {
                    xtype:'textfield',
                    fieldLabel:'Logout To',
                    allowBlank:false,
                    id:'loginWidgetLogoutTo'
                }
                ]
            }),
            buttons: [{
                text:'Submit',
                listeners:{
                    'click':function(button){
                        var window = button.findParentByType('window');
                        var formPanel = window.findByType('form')[0];
                        var logoutTo = formPanel.getForm().findField('loginWidgetLogoutTo').getValue();
                        var logintTo = formPanel.getForm().findField('loginWidgetLoginTo').getValue();

                        //add rendered template to center region editor
                        Ext.getCmp('knitkitCenterRegion').addContentToActiveCodeMirror('<%= render_widget :login, :params => {:logout_to => "'+logoutTo+'", :login_to => "'+logintTo+'"} %>');
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
    onClick:"Compass.ErpApp.Widgets.Login.addLogin();"
});


