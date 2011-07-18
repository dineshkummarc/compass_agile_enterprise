Ext.define("Compass.ErpApp.Desktop.Applications.UserManagement.PersonalInfoPanel",{
    extend:"Ext.Panel",
    alias:'widget.usermanagement_personalinfopanel',
    setWindowStatus : function(status){
        this.findParentByType('statuswindow').setStatus(status);
    },
    
    clearWindowStatus : function(){
        this.findParentByType('statuswindow').clearStatus();
    },

    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.UserManagement.PersonalInfoPanel.superclass.initComponent.call(this, arguments);
    },
  
    constructor : function(config) {
        var form;
        if(config['entityType'] == 'Organization'){
            form = new Ext.FormPanel({
                labelWidth: 110,
                frame:false,
                bodyStyle:'padding:5px 5px 0',
                width: 425,
                url:'./contacts/create_party',
                defaults: {
                    width: 225
                },
                items: [
                {
                    xtype:'textfield',
                    fieldLabel:'Description',
                    value:config['entityInfo']['description'],
                    name:'description'
                }
                ]
            });
        }
        else{
            form = new Ext.FormPanel({
                labelWidth: 110,
                frame:false,
                bodyStyle:'padding:5px 5px 0',
                width: 425,
                url:'./contacts/create_party',
                defaults: {
                    width: 225
                },
                items: [
                {
                    xtype:'textfield',
                    fieldLabel:'First Name',
                    value:config['entityInfo']['current_first_name'],
                    name:'current_first_name'
                },
                {
                    xtype:'textfield',
                    fieldLabel:'Last Name',
                    value:config['entityInfo']['current_last_name'],
                    name:'current_last_name'
                },
                {
                    xtype:'textfield',
                    fieldLabel:'Gender',
                    value:config['entityInfo']['gender'],
                    name:'gender'
                },
                {
                    xtype:'textfield',
                    fieldLabel:'Total Yrs Work Exp',
                    value:config['entityInfo']['total_years_work_experience'],
                    name:'total_years_work_experience'
                }
                ]
            });
        }

        config = Ext.apply({
            items:[form],
            layout:'fit',
            title:config['entityType'] + ' Information'
            }, config);

        Compass.ErpApp.Desktop.Applications.UserManagement.PersonalInfoPanel.superclass.constructor.call(this, config);
    }
});
