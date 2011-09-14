Ext.define("Compass.ErpApp.Login.Window",{
    extend:"Ext.window.Window",
    alias:"compass.erpapp.login.window",
    requires:["Ext.Window"],
    layout:'fit',
    width:200,
    height:240,
	title:'Compass AE Single Sign On',
    defaultButton:'login',
	buttonAlign:'center',
    closable:false,
    plain: true,
	submitForm: function(){
        var self = this;
        var formPanel = this.query('form')[0];
		if(formPanel.getForm().isValid()){
			var login     = Ext.getCmp('login').getValue();
			var password  = Ext.getCmp('password').getValue();
			var loginTo   = Ext.getCmp('loginTo').getValue();
			var waitMsg = Ext.Msg.wait('Status','Authenticating...');
			var conn = new Ext.data.Connection();
	        var data = {authenticity_token: self.initialConfig['authenticity_token'], logout_to: self.initialConfig['logoutTo'], remote: true, commit: "Sign in", utf8: "✓",user: {remember_me: 1, password: password, login: login}};
	        conn.request({
	            url: '/users/sign_in',
	            method: 'POST',
	            jsonData:data,
	            success: function(response) {
	                waitMsg.close();
					result = Ext.decode(response.responseText);
					if(result.success){
						window.location = loginTo;
					}
					else{
						Ext.Msg.alert("Status", result.errors.reason);
					}
	            },
	            failure: function(response) {
	                waitMsg.close();
					var message = 'Error Authenticating'
	                result = Ext.decode(response.responseText);
					if(!Compass.ErpApp.Utility.isBlank(result) && !Compass.ErpApp.Utility.isBlank(result.errors)){
						message = result.errors.reason;
					}
					Ext.Msg.alert("Status", message);
	            }
	        });
		}
    },
	constructor: function(config){
        var formPanel = Ext.create("Ext.FormPanel",{
	        labelWidth: 75,
	        frame:false,
	        bodyStyle:'padding:5px 5px 0',
	        url:'/users/sign_in',
	        fieldDefaults: {
				labelAlign: 'top',
				msgTarget: 'side'
			},
	        items: [
			{
	            xtype:'label',
	            cls:'error_message',
	            text:config.message
	        },
	        {
				xtype:'combo',
				fieldLabel:'Login To',
				allowBlank:false,
				forceSelection:true,
				editable:false,
				id:'loginTo',
	            name:'loginTo',
				store:config.appContainers
			},
			{
	            xtype:'textfield',
	            fieldLabel:'Username or Email Address',
	            allowBlank:false,
	            id:'login',
	            name:'login',
	            listeners: {
	                'specialkey': function(field, e){
	                    if (e.getKey() == e.ENTER) {
	                        var window = field.findParentByType('window');
	                        window.submitForm();
	                    }
	                }
	            }
	        },
	        {
	            xtype:'textfield',
	            fieldLabel:'Password',
	            inputType: 'password',
	            allowBlank:false,
	            id:'password',
				name:'password',
	            listeners: {
	                'specialkey': function(field, e){
	                    if (e.getKey() == e.ENTER) {
	                        var window = field.findParentByType('window');
	                        window.submitForm();
	                    }
	                }
	            }
	        }
	        ]
	    });
	    
        config = Ext.apply({
            items:formPanel,
			buttons: [{
	        text:'Submit',
	        listeners:{
	           	 'click':function(button){
		                var window = button.findParentByType('window');
		                window.submitForm();
		            }
	        	}
	    	}]
        }, config);
        this.callParent([config]);
    }
});