Compass.ErpApp.Desktop.Applications.ControlPanel.DesktopManagementPanel = Ext.extend(Ext.Panel, {
    setup:function(){
        this.form.setup();
    },

    buildPreferenceForm: function(form, preferenceTypes){
        var self = this;
        form.removeAll(true);

        Ext.each(preferenceTypes, function(preferenceType){
            var store = []
            Ext.each(preferenceType.preference_options,function(option){
                store.push([option.value,option.description])
            });

            if(preferenceType.internal_identifier == 'desktop_background')
            {
                form.add({
                    xtype:'combo',
                    fieldLabel:preferenceType.description,
                    editable:false,
                    forceSelection:true,
                    id:preferenceType.internal_identifier + '_id',
                    width:150,
                    triggerAction: 'all',
                    store:store,
                    hiddenName:preferenceType.internal_identifier,
                    listeners:{
                        scope:self,
                        'select':function(combo){
                            self.wallpaperImageChange(combo.getValue());
                        }
                    }
                });
            }
            else
            {
                form.add({
                    xtype:'combo',
                    editable:false,
                    forceSelection:true,
                    id:preferenceType.internal_identifier + '_id',
                    fieldLabel:preferenceType.description,
                    hiddenName:preferenceType.internal_identifier,
                    valueField:'field1',
                    width:150,
                    triggerAction: 'all',
                    store:store
                });
            }

        });
    },

    setPreferences: function(preferences){
        var preference = preferences.find("preference_type.internal_identifier == 'desktop_background'");
        var wallpaper = preference.preference_option.value;
        var img = Ext.get('wallpaper_background_image').dom;
        img.src = "../../images/wallpaper/" + wallpaper;
    },

    wallpaperImageChange: function(selectedImage){
        var img = Ext.get('wallpaper_background_image').dom;
        img.src = "../../images/wallpaper/" + selectedImage;
    },

    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.ControlPanel.DesktopManagementPanel.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        var self = this;
        var backgroundImagePanel = {
            layout:'fit',
            width:150,
            xtype:'panel',
            region:'east',
            html:'<div style="padding:5px;text-align:center"><span>Preview</span><br/><img height=140 width=140 id="wallpaper_background_image" src="../../images/wallpaper/desktop.gif" /><br/></div>'
        }

        this.form = new Compass.ErpApp.Shared.PreferenceForm({
            updateUrl:'./control_panel/desktop_management/update_desktop_preferences',
            setupPreferencesUrl:'./control_panel/desktop_management/desktop_preferences',
            loadPreferencesUrl:'./control_panel/desktop_management/selected_desktop_preferences',
            width:350,
            defaults:{
                width:150
            },
            region:'center',
            listeners:{
                'beforeAddItemsToForm':function(form, preferenceTypes){
                    self.buildPreferenceForm(form, preferenceTypes);
                    return false;
                },
                'beforeSetPreferences':function(form,preferences){
                    self.setPreferences(preferences);
                },
                'afterUpdate':function(form,preferences){
                    var preference = preferences.find("preference_type.internal_identifier == 'desktop_background'");
                    Ext.get('x-wallpaper').dom.src = "../../images/wallpaper/" + preference.preference_option.value;
                }
            }
        });

        config = Ext.apply({
            title:'Desktop',
            items:[this.form,backgroundImagePanel],
            layout:'border'
        }, config);

        Compass.ErpApp.Desktop.Applications.ControlPanel.DesktopManagementPanel.superclass.constructor.call(this, config);
    }
});

Ext.reg('controlpanel_desktopmanagementpanel', Compass.ErpApp.Desktop.Applications.ControlPanel.DesktopManagementPanel);






