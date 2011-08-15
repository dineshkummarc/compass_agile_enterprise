Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.DatabaseComboBox",{
    extend:"Ext.form.field.ComboBox",
    alias:'widget.railsdbadmin_databasecombo',
    initComponent: function() {
		
        var databaseJsonStore = new Ext.data.Store({
            timeout:60000,
            proxy: {
                type: 'ajax',
                url :'/rails_db_admin/base/databases',
                reader: {
                    type: 'json',
                    root: 'databases'
                }
            },
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
        config = Ext.apply({
            id:'databaseCombo',
            valueField:'value',
            displayField:'display',
            triggerAction:'all',
            editable:false,
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