Ext.define("Compass.ErpApp.Organizer.Applications.Crm.ContactMechanismGrid",{
    extend:"Ext.grid.Panel",
    alias:'widget.contactmechanismgrid',
    initComponent: function() {
        var config = this.initialConfig;
        var store = Ext.create('Ext.data.Store', {
            fields:config['fields'],
            autoLoad: false,
            autoSync: true,
            proxy: {
                type: 'rest',
                url:config['url'] || './crm/contact_mechanism',
                extraParams:{
                    party_id:null,
                    contact_type:config['contactMechanism']
                },
                reader: {
                    type: 'json',
                    successProperty: 'success',
                    idProperty: 'id',
                    root: 'data',
                    totalProperty:'totalCount',
                    messageProperty: 'message'
                },
                writer: {
                    type: 'json',
                    writeAllFields:true,
                    root: 'data'
                },
                listeners: {
                    exception: function(proxy, response, operation){
                        Ext.MessageBox.show({
                            title: 'REMOTE EXCEPTION',
                            msg: 'Error Saving ' + config.title,
                            icon: Ext.MessageBox.ERROR,
                            buttons: Ext.Msg.OK
                        });
                    }
                }
            }
        });
        
        this.store = store;

        this.bbar = Ext.create("Ext.PagingToolbar",{
            pageSize: 30,
            store: store,
            displayInfo: true,
            displayMsg: 'Displaying {0} - {1} of {2}',
            emptyMsg: "No " + config.title
        });

        Compass.ErpApp.Organizer.Applications.Crm.ContactMechanismGrid.superclass.initComponent.call(this, arguments);
    },
    constructor : function(config) {
        if(config['contactPurposeStore'] == null)
        {
            config['contactPurposeStore'] = Ext.create('Ext.data.Store', {
                autoLoad:true,
                proxy: {
                    type: 'ajax',
                    url : './crm/contact_purposes',
                    reader: {
                        type: 'json',
                        root: 'types'
                    }
                },
                fields:[
                {
                    name: 'description'
                },
                {
                    name: 'id'
                }
                ]
            });
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
            editor:{
                xtype:'combo',
                forceSelection:true,
                typeAhead: true,
                mode: 'local',
                displayField:'description',
                valueField:'id',
                triggerAction: 'all',
                store: config['contactPurposeStore'],
                selectOnFocus:true
            },
            width:200
        },
        {
            header: 'Created',
            dataIndex: 'created_at',
            renderer: Ext.util.Format.dateRenderer('m/d/Y H:i:s'),
            width:200
        },
        {
            header: 'Last Update',
            dataIndex: 'updated_at',
            renderer: Ext.util.Format.dateRenderer('m/d/Y H:i:s'),
            width:200
        }
        ]);

        if(!config.validations)
            config.validations = [];
        config.validations = config.validations.concat({
            type: 'presence',
            field: 'contact_purpose_id'
        });

        config.fields = config.fields.concat([
        {
            name:'contact_purpose_id'
        },
        {
            name:'created_at'
        },
        {
            name:'updated_at'
        },
        {
            name:'id'
        }
        ]);

        var Model = Ext.define(config.title,{
            extend:'Ext.data.Model',
            fields:config.fields,
            validations:config.validations
        });

        this.editing = Ext.create('Ext.grid.plugin.RowEditing', {
            clicksToMoveEditor: 1
        });

        config = Ext.apply({
            layout:'fit',
            frame: false,
            region:'center',
            loadMask:true,
            plugins:[this.editing],
            tbar:{
                items:[{
                    text: 'Add',
                    xtype:'button',
                    iconCls: 'icon-add',
                    handler: function(button) {
                        var grid = button.findParentByType('contactmechanismgrid');
                        var edit = grid.editing;
                        grid.store.insert(0, new Model());
                        edit.startEdit(0,0);
                    }
                },
                '-',
                {
                    text: 'Delete',
                    type:'button',
                    iconCls: 'icon-delete',
                    handler: function(button) {
                        var grid = button.findParentByType('contactmechanismgrid');
                        var selection = grid.getView().getSelectionModel().getSelection()[0];
                        if (selection) {
                            grid.store.remove(selection);
                        }
                    }
                }]
            }
        }, config);
        Compass.ErpApp.Organizer.Applications.Crm.ContactMechanismGrid.superclass.constructor.call(this, config);
    }
});