Compass.ErpApp.Desktop.Applications.ControlPanel.ApplicationManagementPanel = Ext.extend(Ext.Panel, {
    setWindowStatus : function(status){
        this.findParentByType('statuswindow').setStatus(status);
    },
    
    clearWindowStatus : function(){
        this.findParentByType('statuswindow').clearStatus();
    },

    selectApplication: function(applicationId){
        this.settingsCard.removeAll(true);
        var form = new Compass.ErpApp.Shared.PreferenceForm({
            updateUrl:"./control_panel/application_management/update/" + applicationId,
            setupPreferencesUrl:"./control_panel/application_management/setup/" + applicationId,
            loadPreferencesUrl:"./control_panel/application_management/preferences/" + applicationId,
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
                    var responseObj = Ext.util.JSON.decode(response.responseText);
                    if(responseObj.success){
                        if(responseObj.shortcut == 'yes')
                        {
                            Ext.get(responseObj.shortcutId + '-shortcut').applyStyles('display:block');
                        }
                        else
                        {
                            Ext.get(responseObj.shortcutId + '-shortcut').applyStyles('display:none');
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

    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.ControlPanel.ApplicationManagementPanel.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        this.applicationsTree = new Ext.tree.TreePanel({
            animate:false,
            autoScroll:true,
            region:'west',
            loader: new Ext.tree.TreeLoader({
                dataUrl:'./control_panel/application_management/current_user_applcations'
            }),
            enableDD:false,
            containerScroll: true,
            border: false,
            width:200,
            frame:true,
            root:new Ext.tree.AsyncTreeNode({
                text: 'Applications',
                draggable:false
            }),
            listeners:{
                scope:this,
                'click':function(node){
                    if(node.attributes['leaf'])
                    {
                        this.selectApplication(node.id);
                    }
                }
            }
        });

        this.settingsCard = new Ext.Panel({
            layout:'card',
            region:'center',
            autoDestroy:true
        });

        config = Ext.apply({
            title:'Applications',
            layout:'border',
            items:[this.applicationsTree, this.settingsCard]
        }, config);

        Compass.ErpApp.Desktop.Applications.ControlPanel.ApplicationManagementPanel.superclass.constructor.call(this, config);
    }
});

Ext.reg('controlpanel_applicationmanagementpanel', Compass.ErpApp.Desktop.Applications.ControlPanel.ApplicationManagementPanel);



