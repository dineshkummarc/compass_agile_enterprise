Ext.define("Compass.ErpApp.Desktop.Applications.ControlPanel.ApplicationManagementPanel",{
    extend:"Ext.Panel",
    alias:"widget.controlpanel_applicationmanagementpanel",
    setWindowStatus : function(status){
        this.findParentByType('statuswindow').setStatus(status);
    },
    
    clearWindowStatus : function(){
        this.findParentByType('statuswindow').clearStatus();
    },

    selectApplication: function(applicationId){
        var self = this;
        this.settingsCard.removeAll(true);
        var form = new Compass.ErpApp.Shared.PreferenceForm({
            url:"/erp_app/desktop/control_panel/application_management/update/" + applicationId,
            setupPreferencesUrl:"/erp_app/desktop/control_panel/application_management/setup/" + applicationId,
            loadPreferencesUrl:"/erp_app/desktop/control_panel/application_management/preferences/" + applicationId,
            width:350,
            defaults:{
                width:150
            },
            region:'center',
            listeners:{
                'beforeAddItemsToForm':function(form, preferenceTypes){
                    
                },
                'beforeSetPreferences':function(form,preferences){
                   
                },
                'afterUpdate':function(form,preferences, response){
                    var responseObj = Ext.decode(response.responseText);
                    if(responseObj.success){
                        var shortcut = Ext.create("Ext.ux.desktop.ShortcutModel",{
                            name:responseObj.description,
                            iconCls:responseObj.shortcutId + "-shortcut",
                            module:responseObj.shortcutId
                        });
                        if(responseObj.shortcut == 'yes')
                        {
                            compassDesktop.getDesktop().addShortcut(shortcut);
                        }
                        else
                        {
                            compassDesktop.getDesktop().removeShortcut(shortcut);
                        }
                    }
                    else{
                        Ext.Msg.alert('Status', 'Error updating application settings.');
                    }
                }
            }
        });

        this.settingsCard.add(form);
        this.settingsCard.getLayout().setActiveItem(0);
        form.setup();
    },

    constructor : function(config) {

        var store = Ext.create('Ext.data.TreeStore', {
            proxy: {
                type: 'ajax',
                url: '/erp_app/desktop/control_panel/application_management/current_user_applcations'
            },
            root: {
                text: 'Applications',
                expanded: true
            }
        });

        this.applicationsTree = Ext.create('Ext.tree.Panel', {
            store: store,
            width:200,
            region:'west',
            useArrows: true,
            border: false,
            split:true,
            listeners:{
                scope:this,
                'itemclick':function(view, record){
                    if(record.get('leaf'))
                    {
                        this.selectApplication(record.get('id'));
                    }
                }
            }

        });

        this.settingsCard = new Ext.Panel({
            layout:'card',
            region:'center',
            split:true,
            autoDestroy:true
        });

        config = Ext.apply({
            title:'Applications',
            layout:'border',
            items:[this.applicationsTree, this.settingsCard]
        }, config);

        this.callParent([config]);
    }
});



