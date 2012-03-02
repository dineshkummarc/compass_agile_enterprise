Ext.define("Compass.ErpApp.Desktop.Applications.ControlPanel.ProfileManagementPanel",{
    extend:"Ext.Panel",
    alias:"widget.controlpanel_profilemanagementpanel",
    setWindowStatus : function(status){
        this.findParentByType('statuswindow').setStatus(status);
    },
    
    clearWindowStatus : function(){
        this.findParentByType('statuswindow').clearStatus();
    },

    constructor : function(config) {
        var self = this;
        this.emailForm = {xtype:'form',
            labelWidth: 110,
            title:'Update Email',
            anchor:'100% 50%',
            bodyStyle:'padding:5px 5px 0',
            buttonAlign:'left',
            url: '/erp_app/desktop/control_panel/profile_management/update_email',
            items: [
            {
                xtype:'textfield',
                fieldLabel:'New Email',
                allowBlank:false,
                width:300,
                value:currentUser.email,
                name:'email'
            }
            ],
            buttons:[
            {
                text:'Submit',
                listeners:{
                    'click':function(button){
                        var formPanel = button.findParentByType('form');
                        self.setWindowStatus('Updating email ...');
                        formPanel.getForm().submit({
                            reset:false,
                            success:function(form, action){
                                self.clearWindowStatus();
                                var obj =  Ext.decode(action.response.responseText);
                                if(obj.success){
                                    var newEmail = form.getValues().email;
                                    Ext.Msg.alert("Success", 'Email changed to '+newEmail+'.');
                                    currentUser.email = newEmail;
                                }
                                else{
                                    Ext.Msg.alert("Error", obj.msg);
                                }
                            },
                            failure:function(form, action){
                                self.clearWindowStatus();
                                var obj =  Ext.decode(action.response.responseText);
                                if(Compass.ErpApp.Utility.isBlank(obj.message)){
                                    Ext.Msg.alert("Error", 'Error updating email.');
                                }
                                else{
                                    Ext.Msg.alert("Error", obj.message);
                                }
                            }
                        });
                    }
                }
            }
            ]
        };
        
        this.passwordForm = {xtype:'form',
            labelWidth: 110,
            title:'Update Password',
            anchor:'100% 50%',
            bodyStyle:'padding:5px 5px 0',
            buttonAlign:'left',
            url: '/erp_app/desktop/control_panel/profile_management/update_password',
            defaults: {
                width: 225
            },
            items: [
            {
                xtype:'textfield',
                fieldLabel:'Old Password',
                allowBlank:false,
                name:'old_password',
                inputType: 'password'
            },
            {
                xtype:'textfield',
                fieldLabel:'New Password',
                allowBlank:false,
                name:'password',
                inputType: 'password'
            },
            {
                xtype:'textfield',
                fieldLabel:'Confirm Password',
                allowBlank:false,
                name:'password_confirmation',
                inputType: 'password'
            }
            ],
            buttons:[
            {
                text:'Submit',
                listeners:{
                    'click':function(button){
                        var formPanel = button.findParentByType('form');
                        self.setWindowStatus('Updating password ...');
                        formPanel.getForm().submit({
                            reset:true,
                            success:function(form, action){
                                self.clearWindowStatus();
                                var obj =  Ext.decode(action.response.responseText);
                                if(obj.success){
                                    Ext.Msg.alert("Success", 'Password changed.');
                                }
                                else{
                                    Ext.Msg.alert("Error", obj.msg);
                                }
                            },
                            failure:function(form, action){
                                self.clearWindowStatus();
                                var obj =  Ext.decode(action.response.responseText);
                                if(Compass.ErpApp.Utility.isBlank(obj.message)){
                                    Ext.Msg.alert("Error", 'Error updating password.');
                                }
                                else{
                                    Ext.Msg.alert("Error", obj.message);
                                }
                            }
                        });
                    }
                }
            }
            ]
        };

        config = Ext.apply({
            title:'Profile',
            layout:'anchor',
            items:[this.passwordForm, this.emailForm]
        }, config);

        this.callParent([config]);
    }
});



