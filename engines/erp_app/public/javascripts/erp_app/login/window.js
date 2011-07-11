Ext.define("Compass.ErpApp.Login.Window",{
    extend:"Ext.window.Window",
    alias:"compass.erpapp.login.window",
    requires:["Ext.Window"],
    layout:'fit',
    width:350,
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
            value:this.logout
        },
        {
            xtype:'label',
            cls:'error_message',
            text:this.message
        }
        ],
        keys: [
        {
            key: [Ext.EventObject.ENTER],
            handler: function() {
                alert(this);
            }
        }
        ]
    }),
    buttons: [{
        text:'Submit',
        listeners:{
            'click':function(button){
                var window = button.findParentByType('window');
                window.submitForm();
            }
        }
    }],
    submitForm: function(){
        var self = this;
        var formPanel = this.query('form')[0];
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
    }
});