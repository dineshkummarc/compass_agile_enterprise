Ext.define("Compass.ErpApp.Shared.PreferenceForm",{
    extend:"Ext.form.Panel",
    alias:"widget.preferences_form",
    preferences:null,
    autoScroll:true,
    layout: {
        type: 'vbox'
    },
    fieldDefaults: {
        labelAlign: 'top'
    },
    frame:true,
    buttonAlign:'left',
    items:[],
    buttons:[
    {
        text:'Update',
        handler:function(button){
            var self = button.findParentByType('preferences_form');
            self.setWindowStatus('Updating Preferences...');
            self.getForm().submit({
                reset:false,
                success:function(form, action){
                    var response = Ext.decode(action.response.responseText);
                    var result = self.fireEvent('afterUpdate', self, response.preferences, action.response)
                    if(result !== false)
                        self.setPreferences(response.preferences);
                },
                failure:function(form, action){
                    var message = 'Error Saving Preferences'
                    Ext.Msg.alert("Status", message);
                    self.clearWindowStatus();
                }
            });
        }
    }],

    setWindowStatus : function(status){
        if(this.findParentByType('statuswindow')){
            this.findParentByType('statuswindow').setStatus(status);
        }
        else{
            this.wait = Ext.MessageBox.show({
                msg: 'Processing your request, please wait...',
                progressText: 'Working...',
                width:300,
                wait:true,
                waitConfig: {
                    interval:200
                },
                iconCls:'icon-gear'
            });
        }
    },

    clearWindowStatus : function(){
        if(this.findParentByType('statuswindow')){
            this.findParentByType('statuswindow').clearStatus();
        }
        else{
            this.wait.hide();
        }
    },

    setup: function(){
        this.disable();
        this.setWindowStatus('Loading Preferences...');
        var self = this;
        Ext.Ajax.request({
            url: self.initialConfig.setupPreferencesUrl,
            success: function(responseObject) {
                var response = Ext.decode(responseObject.responseText);
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
                    name:preferenceType.internal_identifier,
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
        Ext.Ajax.request({
            url: self.initialConfig.loadPreferencesUrl,
            success: function(responseObject) {
                var response = Ext.decode(responseObject.responseText);
                self.setPreferences(response.preferences);
            },
            failure: function() {
                Ext.Msg.alert('Status', 'Error loading preferences.');
            }
        });
    },

    setPreferences: function(preferences){
        var self = this;
        self.preferences = preferences
        var result = this.fireEvent('beforeSetPreferences', self, preferences);
        if(result !== false)
        {
            Ext.each(preferences,function(preference){
                var id = "#"+preference.preference_type.internal_identifier + '_id';
                self.query(id).first().setValue(preference.preference_option.value);
            });
        }
        this.fireEvent('afterSetPreferences', self, preferences);
        self.enable();
        self.clearWindowStatus();
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

        this.callParent(arguments);
    }
});
