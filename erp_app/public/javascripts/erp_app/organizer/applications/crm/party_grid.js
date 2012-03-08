Ext.define("Compass.ErpApp.Organizer.Applications.Crm.PartyGrid",{
    extend:"Ext.grid.Panel",
    alias:'widget.partygrid',
    initComponent: function() {
        this.addEvents(
            /**
             * @event addpartybtnclick
             * Fires when add party button is clicked.
             * @param {Ext.Panel} btn the button that was click.
             * @param {Compass.ErpApp.PartyGrid} grid reference to the PartyGrid.
             */
            'addpartybtnclick'
            );
        this.addEvents(
            /**
             * @event editpartybtnclick
             * Fires when add party button is clicked.
             * @param {Ext.Panel} btn the button that was click.
             * @param {Compass.ErpApp.PartyGrid} grid reference to the PartyGrid.
             */
            'editpartybtnclick'
            );

        var grid = this;
        var config = this.initialConfig;
        var store = Ext.create('Ext.data.Store', {
            fields:config.fields,
            autoLoad: false,
            autoSync: true,
            proxy: {
                type: 'rest',
                url:config.url || '/erp_app/organizer/crm/parties',
                extraParams:{
                    party_name:null,
                    party_type:config.partyType
                },
                reader: {
                    type: 'json',
                    successProperty: 'success',
                    idProperty: 'business_party.id',
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
                            msg: 'Error Saving ' + config.partyType,
                            icon: Ext.MessageBox.ERROR,
                            buttons: Ext.Msg.OK
                        });
                    }
                }
            }
        });
 
        var toolBar = Ext.create("Ext.toolbar.Toolbar",{
            items:[
            '<span class="x-btn-inner">'+ this.initialConfig.partyType +' Name:</span>',
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
                        if(searchValue != ''){
                            store.proxy.extraParams.party_name = searchValue;
                        }
                        else{
                            store.proxy.extraParams.party_name = null;
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
                    store.proxy.extraParams.party_name = null;
                    store.load();
                }
            },
            '|',
            {
                text: 'Add',
                xtype:'button',
                iconCls: 'icon-add',
                handler: function(button) {
                    grid.fireEvent('addpartybtnclick', this, grid);
                }
            }            
            ]
        });

        this.store = store;
        this.tbar = toolBar;

        this.bbar = Ext.create("Ext.PagingToolbar",{
            pageSize: 30,
            store: store,
            displayInfo: true,
            displayMsg: 'Displaying {0} - {1} of {2}',
            emptyMsg: "No Parties"
        });

        this.callParent(arguments);
    },
    constructor : function(config) {
        var columns = [
        {
            header: 'Enterprise Identifier',
            dataIndex: 'enterprise_identifier',
            editor: {
                xtype:'textfield'
            },
            width:120
        }];

        var fields = [
        {
            name:'id'
        },
        {
            name:'business_party_id',
            mapping:'business_party.id'
        },
        {
            name:'enterprise_identifier',
            allowBlank:true
        },
        {
            name:'created_at'
            
        },
        {
            name:'updated_at'
        }
        ];

        if(config.partyType == 'Organization'){
            columns = columns.concat([
            {
                header: 'Description',
                dataIndex: 'description',
                editor: {
                    xtype:'textfield'
                },
                width:135
            },
            {
                header: 'Tax ID',
                dataIndex: 'tax_id_number',
                editor: {
                    xtype:'textfield'
                },
                width:120
            }
            ]);

            fields = fields.concat([
            {
                name:'description',
                mapping:'business_party.description',
                allowBlank:false
            },
            {
                name:'tax_id_number',
                mapping:'business_party.tax_id_number',
                allowBlank:false
            }
            ]);
        }
        else{
            columns = columns.concat([
            {
                header: 'Title',
                dataIndex: 'current_personal_title',
                editor: {
                    xtype:'textfield'
                },
                width:120
            },
            {
                header: 'First Name',
                dataIndex: 'current_first_name',
                editor: {
                    xtype:'textfield'
                },
                allowBlank:false,
                width:120
            },
            {
                header: 'Middle Name',
                dataIndex: 'current_middle_name',
                editor: {
                    xtype:'textfield'
                },
                width:120
            },
            {
                header: 'Last Name',
                dataIndex: 'current_last_name',
                editor: {
                    xtype:'textfield'
                },
                allowBlank:false,
                width:120
            },
            {
                header: 'Suffix',
                dataIndex: 'current_suffix',
                editor: {
                    xtype:'textfield'
                },
                width:120
            },
            {
                header: 'Nickname',
                dataIndex: 'current_nickname',
                editor: {
                    xtype:'textfield'
                },
                width:120
            },
            {
                header: 'Passport Number',
                dataIndex: 'current_passport_number',
                editor: {
                    xtype:'textfield'
                },
                width:120
            },
            {
                header: 'Passport Expiration Date',
                dataIndex: 'current_passport_expire_date',
                renderer: Ext.util.Format.dateRenderer('m/d/Y'),
                editor: {
                    xtype: 'datefield',
                    allowBlank: true
                },
                width:135
            },
            {
                header: 'DOB',
                dataIndex: 'birth_date',
                renderer: Ext.util.Format.dateRenderer('m/d/Y'),
                editor: {
                    xtype: 'datefield',
                    allowBlank: false
                },
                allowBlank:false,
                width:135
            },
            {
                header: 'Gender',
                dataIndex: 'gender',
                editor: {
                    xtype:'textfield'
                },
                allowBlank:false,
                width:75
            },
            {
                header: 'Total Yrs Work Exp',
                dataIndex:'total_years_work_experience',
                editor: {
                    xtype:'textfield'
                },
                width:125
            },
            {
                header:'Martial Status',
                dataIndex:'marital_status',
                editor: {
                    xtype:'textfield'
                },
                width:120
            },
            {
                header:'SSN Last Four',
                dataIndex:'ssn_last_four',
                width:125
            }
            ]);

            fields = fields.concat([
            {
                name:'current_first_name',
                mapping:'business_party.current_first_name',
                allowBlank:false
            },

            {
                name:'current_last_name',
                mapping:'business_party.current_last_name',
                allowBlank:false
            },


            {
                name:'current_middle_name',
                mapping:'business_party.current_middle_name',
                allowBlank:true
            },


            {
                name:'current_personal_title',
                mapping:'business_party.current_personal_title',
                allowBlank:true
            },

            {
                name:'current_nickname',
                mapping:'business_party.current_nickname',
                allowBlank:true
            },

            {
                name:'current_suffix',
                mapping:'business_party.current_suffix',
                allowBlank:true
            },

            {
                name:'current_passport_number',
                mapping:'business_party.current_passport_number',
                allowBlank:true
            },

            {
                name:'current_passport_expire_date',
                mapping:'business_party.current_passport_expire_date',
                type: 'date',
                dateFormat:'Y-m-d',
                allowBlank:true
            },
            {
                name:'gender',
                mapping:'business_party.gender',
                allowBlank:false
            },

            {
                name:'birth_date',
                mapping:'business_party.birth_date',
                type: 'date',
                dateFormat:'Y-m-d',
                allowBlank:false
            },

            {
                name:'total_years_work_experience',
                mapping:'business_party.total_years_work_experience',
                allowBlank:true
            },
            {
                name:'marital_status',
                mapping:'business_party.marital_status',
                allowBlank:true
            },
            {
                name:'ssn_last_four',
                mapping:'business_party.ssn_last_four',
                allowBlank:true
            }
            ]);
        }

        columns = columns.concat([
        {
            header: 'Created',
            dataIndex: 'created_at',
            renderer: Ext.util.Format.dateRenderer('m/d/Y g:i a'),
            width:120
        },
        {
            header: 'Last Update',
            dataIndex: 'updated_at',
            renderer: Ext.util.Format.dateRenderer('m/d/Y g:i a'),
            width:120
        }
        ]);

        //this.editing = Ext.create('Ext.grid.plugin.RowEditing', {
        //    clicksToMoveEditor: 1
        //});

        config = Ext.apply({
            columns:columns,
            fields:fields,
            layout:'fit',
            frame: false,
            autoScroll:true,
            region:'center',
            //plugins:[this.editing],
            loadMask:true
        }, config);
        
		this.callParent([config]);
    }
});


