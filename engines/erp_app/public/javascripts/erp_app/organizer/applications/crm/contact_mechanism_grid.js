Compass.ErpApp.Organizer.Applications.Crm.ContactMechanismGrid = Ext.extend(Ext.grid.GridPanel, {
    initComponent: function() {
        var messageBox = null;

        var proxy = new Ext.data.HttpProxy({
            url:this.initialConfig['url'] || './crm/contact_mechanism'
        });

        proxy.addListener('exception', function(proxy, type, action, options, res) {
            var message = 'Error in processing request';
            if(!Compass.ErpApp.Utility.isBlank(res.message))
                message = res.message;
            Ext.Msg.alert('Error', message);
        });

        proxy.addListener('beforewrite', function(proxy, action) {
            if(messageBox != null)
                messageBox.hide();

            var messageBox = Ext.Msg.wait('Status', 'Sending request...');
        });

        proxy.addListener('write', function(dataProxy, action, data, response, rs, options) {
            var message = "Request processed"

            if(messageBox != null)
                messageBox.hide();

            rs.dirty = false;
            rs.commit();

            if(!Compass.ErpApp.Utility.isBlank(response.message))
                message = response.message;

            Ext.Msg.alert('Status', message);
        });

        var reader = new Ext.data.JsonReader({
            successProperty: 'success',
            totalProperty:'totalCount',
            idProperty: 'id',
            root: 'data',
            messageProperty: 'message'
        },
        this.initialConfig['fields']);

        var writer = new Ext.data.JsonWriter({
            encode: false
        });

        var store = new Ext.data.Store({
            restful: true,
            proxy: proxy,
            reader: reader,
            writer: writer,
            baseParams:{
                party_id:null,
                contact_type:this.initialConfig['contactMechanism']
            },
            listeners:{
                'exception':function(){
                    Ext.Msg.alert("Error", arguments[5]);
                }
            }
        });
        
        this.store = store;

        
        Compass.ErpApp.Organizer.Applications.Crm.ContactMechanismGrid.superclass.initComponent.call(this, arguments);
    },
    constructor : function(config) {
        if(config['contactPurposeStore'] == null)
        {
            var contactPurposeStore = new Compass.ErpApp.Utility.Data.TypeJsonStore({
                xtype:'combobox',
                url: './crm/contact_purposes'
            });
            config['contactPurposeStore'] = contactPurposeStore
            contactPurposeStore.load();
        }

        config.columns = config.columns.concat([
        {
            header: 'Contact Purpose',
            dataIndex: 'contact_purpose_id',
            renderer:function(){
                var record = arguments[2];
                if(!Compass.ErpApp.Utility.isBlank(record.data['contact_purpose_id'])){
                    return config['contactPurposeStore'].getAt(config['contactPurposeStore'].find("id", record.data['contact_purpose_id'])).get("description");
                }
                else{
                    return '';
                }
            },
            editor: new Ext.form.ComboBox({
                forceSelection:true,
                typeAhead: true,
                mode: 'local',
                displayField:'description',
                valueField:'id',
                triggerAction: 'all',
                store: config['contactPurposeStore'],
                selectOnFocus:true
            }),
            width:200
        },
        {
            header: 'Created',
            dataIndex: 'created_at',
            width:200
        },
        {
            header: 'Last Update',
            dataIndex: 'updated_at',
            width:200
        }
        ]);

        //undefined gets in this array some how this removes it
        Ext.each(config.fields, function(field){
            if(field == undefined || field.name == undefined || field.name == 'undefined'){
                config.fields.remove(field);
            }
        });

        var Record = Ext.data.Record.create(config.fields);
        
        config.fields = config.fields.concat([
        {
            name:'contact_purpose_id'
        },
        {
            name:'created_at'
        },
        {
            name:'updated_at'
        }
        ])

        var editor = new Ext.ux.grid.RowEditor({
            saveText: 'Update',
            buttonAlign:'center',
            errorSummary: false,
            RowEditor:true,
            listeners:{
                'validateedit':function(rowEditor, changes, record, rowIndex){
                    
                }
            }
        });

        config = Ext.apply({
            layout:'fit',
            frame: false,
            autoScroll:true,
            region:'center',
            loadMask:true,
            plugins:[editor],
            tbar:{
                items:[{
                    text: 'Add',
                    iconCls: 'icon-add',
                    handler: function(button) {
                        var grid = button.findParentByType('contactmechanismgrid');
                        var u = new Record();
                        editor.stopEditing();
                        grid.store.insert(0, u);
                        editor.startEditing(0);
                    }
                },
                '-',
                {
                    text: 'Delete',
                    iconCls: 'icon-delete',
                    handler: function(button) {
                        var grid = button.findParentByType('contactmechanismgrid');
                        var rec = grid.getSelectionModel().getSelected();
                        if (!rec) {
                            return false;
                        }
                        grid.store.remove(rec);
                    }
                }]
            }
        }, config);
        Compass.ErpApp.Organizer.Applications.Crm.ContactMechanismGrid.superclass.constructor.call(this, config);
    }
});

Ext.reg('contactmechanismgrid', Compass.ErpApp.Organizer.Applications.Crm.ContactMechanismGrid);

