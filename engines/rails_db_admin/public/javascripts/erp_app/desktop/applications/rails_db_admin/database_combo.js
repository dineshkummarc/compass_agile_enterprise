Compass.ErpApp.Desktop.Applications.RailsDbAdmin.DatabaseComboBox = Ext.extend(Ext.form.ComboBox, {
    initComponent: function() {
		
        var databaseJsonStore = new Ext.data.JsonStore({
            timeout:60000,
            root:'databases',
            url:'./rails_db_admin/base/databases',
            fields: [{
                name:'value'
            },{
                name:'display'
            }]
        });
	
        this.store = databaseJsonStore;
		
        databaseJsonStore.load();
		
        Compass.ErpApp.Desktop.Applications.RailsDbAdmin.DatabaseComboBox.superclass.initComponent.call(this, arguments);
    },
    
    constructor : function(config) {
        var self = this;
        config = Ext.apply({
            id:'databaseCombo',
            valueField:'value',
            displayField:'display',
            triggerAction:'all',
            forceSelection:true,
            mode:'local',
            value:'development',
            listeners:{
                'select':function(combo, record, index){
                  // switch databases                  
                  combo.initialConfig.module.connectToDatatbase();
                }
            }
        }, config);
        Compass.ErpApp.Desktop.Applications.RailsDbAdmin.DatabaseComboBox.superclass.constructor.call(this, config);
    }
	
});

Ext.reg('railsdbadmin_databasecombo', Compass.ErpApp.Desktop.Applications.RailsDbAdmin.DatabaseComboBox);