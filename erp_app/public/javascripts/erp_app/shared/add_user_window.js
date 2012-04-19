Ext.define("Compass.ErpApp.AddUserWindow",{
    extend:"Ext.window.Window",
    constructor: function(config) {
        var self,defaultConfig;

        self = this;

        defaultConfig = {
            width: 325,
            layout: 'fit',
            title: 'New User',
            plain: true,
            buttonAlign: 'center',
            successCallback: function(response) {
                Ext.Msg.alert("Successfully Created User");

            },
            items: {
                xtype:'form',
                frame: false,
                bodyStyle:'padding:5px 5px 0',
                url:'/users/new',
                defaults: {
                    width: 225,
                    labelWidth: 100
                },
                items: [
                    {
                      emptyText:'Select Gender...',
                      xtype: 'combo',
                      forceSelection:true,
                      store: [['m','Male'],['f','Female']],
                      fieldLabel: 'Gender',
                      name: 'gender',
                      allowBlank: false,
                      triggerAction: 'all'
                    },
                    {
                      xtype:'textfield',
                      fieldLabel:'First Name',
                      allowBlank:false,
                      name:'first_name'
                    },
                    {
                      xtype:'textfield',
                      fieldLabel:'Last Name',
                      allowBlank:false,
                      name:'last_name'
                    },
                    {
                      xtype:'textfield',
                      fieldLabel:'Email',
                      allowBlank:false,
                      name:'email'
                    },
                    {
                      xtype:'textfield',
                      fieldLabel:'Username',
                      allowBlank:false,
                      name:'username'
                    },
                    {
                      xtype:'textfield',
                      fieldLabel:'Password',
                      inputType: 'password',
                      allowBlank:false,
                      name:'password'
                    },
                    {
                      xtype:'textfield',
                      fieldLabel:'Confirm Password',
                      inputType: 'password',
                      allowBlank:false,
                      name:'password_confirmation'
                    },
                    {
                      xtype:'textfield',
                      hidden: true,
                      name: 'party_id',
                      value: config.partyId
                    }
                ]},
            buttons: [{
                 text:'Submit',
                 listeners:{
                   'click':function(button){
                        var window, formPanel;
                        window = button.findParentByType('window');
                        formPanel = window.query('.form')[0];
                        //self.setWindowStatus('Creating user...');
                        formPanel.getForm().submit({
                            reset:true,
                            success:function(form, action){
                                var obj;
                                //self.clearWindowStatus();
                                obj =  Ext.decode(action.response.responseText);
                                if(obj.success){
                                  self.successCallback(action.response);
                                }
                                else{
                                  Ext.Msg.alert("Error", obj.message);
                                }
                            },
                            failure:function(form, action){
                                var obj;
                                //self.clearWindowStatus();

                                if(action.response !== undefined){
                                  obj =  Ext.decode(action.response.responseText);
                                  Ext.Msg.alert("Error", obj.message);
                                }
                                else{
                                  Ext.Msg.alert("Error", 'Error adding user.');
                                }
                            }
                        });
                   }
                 }
            },{
                text: 'Close',
                handler: function(){
                  self.close();
                }
            }]
        };
        Ext.applyIf(config, defaultConfig);
        this.callParent([config]);
    }
});
