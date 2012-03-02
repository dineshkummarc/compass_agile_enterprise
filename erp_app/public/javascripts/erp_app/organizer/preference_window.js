Ext.define("Compass.ErpApp.Organizer.PreferencesWindow",{
    extend:"Ext.window.Window",
    alias:"widget.organizer_preferenceswindow",
    
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
                    name:preferenceType.internal_identifier,
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
                    name:preferenceType.internal_identifier,
                    valueField:'field1',
                    width:150,
                    triggerAction: 'all',
                    store:store
                });
            }

        });
    },

    constructor : function(config) {
        this.form = Ext.create('Compass.ErpApp.Shared.PreferenceForm',{
            url:'/erp_app/organizer/update_preferences',
            setupPreferencesUrl:'/erp_app/organizer/setup_preferences',
            loadPreferencesUrl:'/erp_app/organizer/get_preferences',
            width:350,
            defaults:{
                width:150
            },
            listeners:{
                'beforeAddItemsToForm':function(form, preferenceTypes){
                    return true;
                },
                'beforeSetPreferences':function(form,preferences){
                    //self.setPreferences(preferences);
                },
                'afterUpdate':function(form,preferences){
                    Compass.ErpApp.Utility.promptReload();
                    return false;
                }
            }
        });

        config = Ext.apply({
            title:'Preferences',
            height:300,
            width:300,
            items:[this.form],
            layout:'fit'
        }, config);

        this.callParent([config]);
    }
});