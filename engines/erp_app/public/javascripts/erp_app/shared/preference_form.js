Ext.ns("Compass.ErpApp.Shared");

Compass.ErpApp.Shared.PreferenceForm = Ext.extend(Ext.FormPanel, {

    setup: function(){
        var self = this;
        self.wait = Ext.Msg.wait('Loading Preferences...');
        var conn = new Ext.data.Connection();
        conn.request({
            url: self.initialConfig.setupPreferencesUrl,
            success: function(responseObject) {
                var response =  Ext.util.JSON.decode(responseObject.responseText);
                self.buildPreferenceForm(response.preference_types)
            },
            failure: function() {
                Ext.Msg.alert('Status', 'Error setting up preferences.');
            }
        });
    },

    buildPreferenceForm: function(preferenceTypes){
        var self = this;

        var result = this.fireEvent('beforeAddItemsToForm', self, preferenceTypes);

        if(result != false)
        {
            Ext.each(preferenceTypes, function(preferenceType){
                var store = []
                Ext.each(preferenceType.preference_options,function(option){
                    store.push([option.value,option.description])
                });
                self.add({
                    xtype:'combo',
                    editable:false,
                    forceSelection:true,
                    id:preferenceType.internal_identifier + '_id',
                    fieldLabel:preferenceType.description,
                    hiddenName:preferenceType.internal_identifier,
                    width:150,
                    value:preferenceType.default_value,
                    triggerAction: 'all',
                    store:store
                });
            });
        }
        self.doLayout();
        self.loadPreferences();
    },

    loadPreferences: function(){
        var self = this;
        var conn = new Ext.data.Connection();
        conn.request({
            url: self.initialConfig.loadPreferencesUrl,
            success: function(responseObject) {
                var response =  Ext.util.JSON.decode(responseObject.responseText);
                self.setPreferences(response.preferences);
            },
            failure: function() {
                Ext.Msg.alert('Status', 'Error loading preferences.');
            }
        });
    },

    setPreferences: function(preferences){
        var self = this;
        var result = this.fireEvent('beforeSetPreferences', self, preferences);
        if(result != false)
        {
            Ext.each(preferences,function(preference){
                self.findById(preference.preference_type.internal_identifier + '_id').setValue(preference.preference_option.value);
            });
        }
        this.fireEvent('afterSetPreferences', self, preferences);
        self.wait.hide();
    },

    initComponent: function() {
        this.addEvents(
            /**
         * @event afterAddItemsToForm
         * Fired before loaded preference types a added to form before layout is called
         * if false is returned items are not added to form
         * @param {FormPanel} this
         * @param {Array} array of preferenceTypes
         */
            "beforeAddItemsToForm",
            /**
         * @event afterSetPreferences
         * Fired after preference fields are set with selected preference options
         * @param {FormPanel} this
         * @param {Array} array of preferences
         */
            "beforeSetPreferences",
            /**
         * @event afterSetPreferences
         * Fired before preference fields are set with selected preference options
         * @param {FormPanel} this
         * @param {Array} array of preferences
         */
            "afterSetPreferences",
            /**
         * @event afterSetPreferences
         * Fired after update of preferences
         * @param {FormPanel} this
         * @param {Array} array of updated preferences
         */
            "afterUpdate"
            );

        Compass.ErpApp.Shared.PreferenceForm.superclass.initComponent.call(this, arguments);
    },
    constructor : function(config) {
        var self = this;
        config = Ext.apply({
            url:config.updateUrl,
            autoScroll:true,
            frame:true,
            items:[],
            buttons:[
            {
                text:'Update',
                handler:function(button){
                    self.getForm().submit({
                        reset:false,
                        waitMsg:'Updating Preferences...',
                        success:function(form, action){
                            var response =  Ext.util.JSON.decode(action.response.responseText);
                            self.setPreferences(response.preferences);
                            self.fireEvent('afterUpdate', self, response.preferences, action.response);
                        },
                        failure:function(form, action){
                            var message = 'Error Saving Preferences'
                            Ext.Msg.alert("Status", message);
                        }
                    });
                }
            }
            ]
        }, config);
        Compass.ErpApp.Shared.PreferenceForm.superclass.constructor.call(this, config);
    }

});

Ext.reg('preferences_form', Compass.ErpApp.Shared.PreferenceForm);

