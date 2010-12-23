Ext.ns("Compass.ErpApp.Shared");

Compass.ErpApp.Shared.BooleanEditor = Ext.extend(Ext.form.ComboBox, {
	
    initComponent: function() {
		
        var trueFalseStore = new Ext.data.ArrayStore({
            fields: ['display', 'value'],
            data: [['False', '0'],['True', '1']]
        });
	
        this.store = trueFalseStore;
		
        Compass.ErpApp.Shared.BooleanEditor.superclass.initComponent.call(this, arguments);
    },
    constructor : function(config) {
        config = Ext.apply({
            valueField:'value',
            displayField:'display',
            triggerAction:'all',
            forceSelection:true,
            mode:'local'
        }, config);
        Compass.ErpApp.Shared.BooleanEditor.superclass.constructor.call(this, config);
    }

});

Ext.reg('booleancolumneditor', Compass.ErpApp.Shared.BooleanEditor);