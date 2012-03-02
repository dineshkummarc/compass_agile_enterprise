Ext.define("Compass.ErpApp.Desktop.Applications.DynamicForms.DynamicDataGridPanel",{
    extend:"Compass.ErpApp.Shared.DynamicEditableGridLoaderPanel",
    alias:'widget.dynamic_forms_DynamicDataGridPanel',
    
    editRecord : function(rec, model_name){
        var self = this;
        Ext.getCmp('westregionPanel').setWindowStatus('Getting update form...');
        Ext.Ajax.request({
            url: '/erp_forms/erp_app/desktop/dynamic_forms/forms/get',
            method: 'POST',
            params:{
                id:rec.get("id"),
                model_name:model_name,
                form_action: 'update'
            },
            success: function(response) {
                Ext.getCmp('westregionPanel').clearWindowStatus();
                form_definition = Ext.decode(response.responseText);
                var editRecordWindow = Ext.create("Ext.window.Window",{
                    layout:'fit',
                    title:'Update Record',
                    y: 100, // this fixes chrome and safari rendering the window at the bottom of the screen
                    plain: true,
                    buttonAlign:'center',
                    items: form_definition                            
                });
                Ext.getCmp('dynamic_form_panel').getForm().loadRecord(rec);                
                editRecordWindow.show();  
            },
            failure: function(response) {
                Ext.getCmp('westregionPanel').clearWindowStatus();
                Ext.Msg.alert('Error', 'Error getting form');
            }
        });
    },
    
    deleteRecord : function(rec, model_name){
        var self = this;
        Ext.getCmp('westregionPanel').setWindowStatus('Deleting record...');
        Ext.Ajax.request({
            url: '/erp_forms/erp_app/desktop/dynamic_forms/data/delete',
            method: 'POST',
            params:{
                id:rec.get("id"),
                model_name:model_name
            },
            success: function(response) {
                var obj =  Ext.decode(response.responseText);
                if(obj.success){
                    Ext.getCmp('westregionPanel').clearWindowStatus();
                    self.query('shared_dynamiceditablegrid')[0].store.load();
                }
                else{
                    Ext.Msg.alert('Error', 'Error deleting record');
                    Ext.getCmp('westregionPanel').clearWindowStatus();
                }
            },
            failure: function(response) {
                Ext.getCmp('westregionPanel').clearWindowStatus();
                Ext.Msg.alert('Error', 'Error deleting record');
            }
        });
    },
    
    constructor : function(config) {
        config = Ext.apply({
            id:'DynamicFormDataGridPanel',
            //title:'Dynamic Data',
            editable:false,
            page:true,
            pageSize: 20,
            displayMsg:'Displaying {0} - {1} of {2}',
            emptyMsg:'Empty'
        }, config);

        this.callParent([config]);
    }
});

