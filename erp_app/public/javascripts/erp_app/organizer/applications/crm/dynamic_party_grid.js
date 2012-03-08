Ext.define("Compass.ErpApp.Desktop.Applications.DynamicForms.DynamicPartyGridPanel",{
    extend:"Compass.ErpApp.Shared.DynamicEditableGridLoaderPanel",
    alias:'widget.crmDynamicPartyGridPanel',

    // initComponent: function() {
    //     this.addEvents('itemdblclick');
    // },
    
    constructor : function(config) {
        var self = this;

        var toolBar = Ext.create("Ext.toolbar.Toolbar",{
            items:[
            {
                xtype:'textfield',
                hideLabel:true,
                width:150
            },
            {
                xtype:'button',
                text:'Search',
                iconCls:'icon-search',
                listeners:{
                    'click':function(){
                        var tbar = this.findParentByType('toolbar');
                        var textField = tbar.query('textfield')[0];
                        var searchValue = textField.getValue();
                        store = self.query('shared_dynamiceditablegrid').first().store;
                        if(searchValue != ''){
                            store.proxy.extraParams.query = searchValue;
                        }
                        else{
                            store.proxy.extraParams.query = null;
                        }
                        store.load();
                    }
                }
            },
            '|',
            {
                text: 'All',
                xtype:'button',
                iconCls: 'icon-eye',
                handler: function(button) {
                    store = self.query('shared_dynamiceditablegrid').first().store;
                    store.proxy.extraParams.query = null;
                    store.load();
                }
            },
            '|',
            {
                text: 'Add Individual',
                xtype:'button',
                iconCls: 'icon-add',
                handler: function(button) {
                    self.fireEvent('addpartybtnclick', this, self);
                }
            },       
            {
                text: 'Add Organization',
                xtype:'button',
                iconCls: 'icon-add',
                handler: function(button) {
                    self.fireEvent('addorgbtnclick', this, self);
                }
            }            
            ]
        });

        config = Ext.apply({
            tbar: toolBar,
            id:'DynamicPartyDataGridPanel',
            //title:'Dynamic Data',
            setupUrl: '/erp_app/organizer/crm/setup',
            dataUrl: '/erp_app/organizer/crm/index',
            editable:false,
            page:true,
            pageSize: 20,
            displayMsg:'Displaying {0} - {1} of {2}',
            emptyMsg:'Empty',
            grid_listeners:{
                'itemdblclick':function(view, record, item, index, e, options){
                    var partyId = record.get("id");
                    var partyTab = Ext.getCmp('party_id_' + partyId);
                    if (partyTab){
                      Ext.getCmp('IndividualsCenterPanel').setActiveTab('party_id_' + partyId);
                    }
                    else{
                      openPartyTab(partyId, record, 'Individual');        
                    }
                }
            }
        }, config);

        this.callParent([config]);
    }
});

