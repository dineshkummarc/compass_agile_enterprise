Compass.RailsDbAdmin.DatabaseComboBox = Ext.extend(Ext.form.ComboBox, {
    initComponent: function() {
		
        var databaseJsonStore = new Ext.data.JsonStore({
            timeout:60000,
            root:'databases',
            url:'./base/databases',
            fields: [{
                name:'value'
            },{
                name:'display'
            }]
        });
	
        this.store = databaseJsonStore;
		
        databaseJsonStore.load();
		
        Compass.RailsDbAdmin.DatabaseComboBox.superclass.initComponent.call(this, arguments);
    },
    constructor : function(config) {
        config = Ext.apply({
            id:'databaseCombo',
            valueField:'value',
            displayField:'display',
            triggerAction:'all',
            forceSelection:true,
            mode:'local'
        }, config);
        Compass.RailsDbAdmin.QueryPanel.superclass.constructor.call(this, config);
    }
	
});

Ext.reg('databasecombo', Compass.RailsDbAdmin.DatabaseComboBox);