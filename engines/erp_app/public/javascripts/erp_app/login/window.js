Ext.ns("Compass.ErpApp.Login");

Compass.ErpApp.Login.Window = Ext.extend(Ext.Window, {
    submitForm: function(){
        var self = this;
        var formPanel = this.findByType('form')[0];
        formPanel.getForm().submit({
            reset:false,
            waitMsg:'Authenticating...',
            success:function(form, action){
                window.location = self.initialConfig['redirectTo'];
            },
            failure:function(form, action){
                var message = 'Error Authenticating'
                Ext.Msg.alert("Status", message);
            }
        });
    },

    constructor : function(config) {
        var self = this;
        var appName = config['applicationName'] || ''
        config = Ext.apply({
            layout:'fit',
            width:350,
            title:appName + ' Login',
            height:150,
            defaultButton:'login',
            closable:false,
            buttonAlign:'center',
            plain: true,
            items: new Ext.FormPanel({
                labelWidth: 75,
                frame:false,
                bodyStyle:'padding:5px 5px 0',
                url:Compass.ErpApp.Utility.getRootUrl() + 'erp_app/application/create',
                defaults: {
                    width: 215
                },
                items: [
                {
                    xtype:'textfield',
                    fieldLabel:'Username',
                    allowBlank:false,
                    id:'login',
                    name:'login'
                },
                {
                    xtype:'textfield',
                    fieldLabel:'Password',
                    inputType: 'password',
                    allowBlank:false,
                    name:'password'
                },
                {
                    xtype:'hidden',
                    name:'logout_to',
                    value:config['logoutTo']
                },
                {
                    xtype:'label',
                    cls:'error_message',
                    text:config['message']
                }
                ],
                keys: [
                {
                    key: [Ext.EventObject.ENTER],
                    handler: function() {
                        self.submitForm();
                    }
                }
                ]
            }),
            buttons: [{
                text:'Submit',
                listeners:{
                    'click':function(button){
                        self.submitForm();
                    }
                }
            }]
        }, config);

        Compass.ErpApp.Login.Window.superclass.constructor.call(this, config);
    }
});

Ext.reg('loginmodal', Compass.ErpApp.Login.Window);