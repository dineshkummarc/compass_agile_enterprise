Ext.define("Compass.ErpApp.Desktop.Applications.ControlPanel.ProfileManagementPanel",{
    extend:"Ext.Panel",
    alias:"widget.controlpanel_profilemanagementpanel",
    setWindowStatus : function(status){
        this.findParentByType('statuswindow').setStatus(status);
    },
    
    clearWindowStatus : function(){
        this.findParentByType('statuswindow').clearStatus();
    },

    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.ControlPanel.ProfileManagementPanel.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        var self = this;
        this.passwordForm = new Ext.FormPanel({
            labelWidth: 110,
            frame:false,
            title:'Update Password',
            bodyStyle:'padding:5px 5px 0',
            width: 425,
            autoHeight: true,
            url: './control_panel/profile_management/update_password',
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
                                var obj =  Ext.util.JSON.decode(action.response.responseText);
                                if(obj.success){
                                    Ext.Msg.alert("Success", 'Password changed.');
                                }
                                else{
                                    Ext.Msg.alert("Error", obj.msg);
                                }
                            },
                            failure:function(form, action){
                                self.clearWindowStatus();
                                var obj =  Ext.util.JSON.decode(action.response.responseText);
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
        });

        config = Ext.apply({
            title:'Profile',
            layout:'fit',
            items:[this.passwordForm]
        }, config);

        Compass.ErpApp.Desktop.Applications.ControlPanel.ProfileManagementPanel.superclass.constructor.call(this, config);
    }
});



