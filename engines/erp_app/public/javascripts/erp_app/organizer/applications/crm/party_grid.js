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

        var grid = this;
        var config = this.initialConfig;
        var store = Ext.create('Ext.data.Store', {
            fields:config['fields'],
            autoLoad: true,
            autoSync: true,
            proxy: {
                type: 'rest',
                url:config['url'] || './crm/parties',
                extraParams:{
                    party_name:null,
                    party_type:config['partyType']
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
                            msg: operation.getError(),
                            icon: Ext.MessageBox.ERROR,
                            buttons: Ext.Msg.OK
                        });
                    }
                }
            }
        });
 
        var toolBar = Ext.create("Ext.toolbar.Toolbar",{
            items:[
            '<span style="color:white;font-weight:bold;">'+ this.initialConfig['partyType'] +' Name:</span>',
            {
                xtype:'textfield',
                width:150
            },
            {
                xtype:'button',
                text:'Search',
                iconCls:'icon-search',
                listeners:{
                    'click':function(){
                        var tbar = this.findParentByType('toolbar');
                        var textField = tbar.findByType('textfield')[0];
                        var searchValue = textField.getValue();
                        if(searchValue != ''){
                            store.setBaseParam("party_name", searchValue);
                            store.load();
                        }
                    }
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
            },
            '|',
            {
                text: 'Delete',
                xtype:'button',
                iconCls: 'icon-delete',
                handler: function(button) {
                    var grid = button.findParentByType('partygrid');
                    var rec = grid.getSelectionModel().getSelected();
                    if (!rec) {
                        return false;
                    }
                    grid.store.remove(rec);
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

        Compass.ErpApp.Organizer.Applications.Crm.PartyGrid.superclass.initComponent.call(this, arguments);
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

        if(config['partyType'] == 'Organization'){
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
                header: 'Suffix',
                dataIndex: 'suffix',
                editor: {
                    xtype:'textfield'
                },
                width:120
            },
            {
                header: 'Title',
                dataIndex: 'title',
                editor: {
                    xtype:'textfield'
                },
                width:120
            },
            {
                header: 'First Name',
                dataIndex: 'firstName',
                editor: {
                    xtype:'textfield'
                },
                allowBlank:false,
                width:120
            },
            {
                header: 'Middle Name',
                dataIndex: 'middleName',
                editor: {
                    xtype:'textfield'
                },
                width:120
            },
            {
                header: 'Last Name',
                dataIndex: 'lastName',
                editor: {
                    xtype:'textfield'
                },
                allowBlank:false,
                width:120
            },
            {
                header: 'Nickname',
                dataIndex: 'nickname',
                editor: {
                    xtype:'textfield'
                },
                width:120
            },
            {
                header: 'Passport Number',
                dataIndex: 'passportNumber',
                editor: {
                    xtype:'textfield'
                },
                width:120
            },
            {
                header: 'Passport Expiration Date',
                dataIndex: 'passportExpirationDate',
                renderer: Ext.util.Format.dateRenderer('n/j/Y'),
                editor: {
                    xtype: 'datefield',
                    allowBlank: true
                },
                width:135
            },
            {
                header: 'DOB',
                dataIndex: 'dob',
                renderer: Ext.util.Format.dateRenderer('n/j/Y'),
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
                dataIndex:'totalYearsWorkExperience',
                editor: {
                    xtype:'textfield'
                },
                width:125
            },
            {
                header:'Martial Status',
                dataIndex:'maritalStatus',
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
                name:'firstName',
                mapping:'business_party.current_first_name',
                allowBlank:false
            },

            {
                name:'lastName',
                mapping:'business_party.current_last_name',
                allowBlank:false
            },


            {
                name:'middleName',
                mapping:'business_party.current_middle_name',
                allowBlank:true
            },


            {
                name:'title',
                mapping:'business_party.current_personal_title',
                allowBlank:true
            },

            {
                name:'nickname',
                mapping:'business_party.current_nickname',
                allowBlank:true
            },


            {
                name:'suffix',
                mapping:'business_party.current_suffix',
                allowBlank:true
            },

            {
                name:'passportNumber',
                mapping:'business_party.current_passport_number',
                allowBlank:true
            },


            {
                name:'passportExpirationDate',
                mapping:'business_party.current_passport_expire_date',
                type: 'date',
                allowBlank:true
            },
            {
                name:'gender',
                mapping:'business_party.gender',
                allowBlank:false
            },

            {
                name:'dob',
                mapping:'business_party.birth_date',
                type: 'date',
                allowBlank:false
            },

            {
                name:'totalYearsWorkExperience',
                mapping:'business_party.total_years_work_experience',
                allowBlank:true
            },
            {
                name:'maritalStatus',
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
            width:120
        },
        {
            header: 'Last Update',
            dataIndex: 'updated_at',
            width:120
        }
        ]);

        this.editing = Ext.create('Ext.grid.plugin.RowEditing', {
            clicksToMoveEditor: 1
        });

        config = Ext.apply({
            columns:columns,
            fields:fields,
            layout:'fit',
            frame: false,
            autoScroll:true,
            region:'center',
            plugins:[this.editing],
            loadMask:true
        }, config);
        Compass.ErpApp.Organizer.Applications.Crm.PartyGrid.superclass.constructor.call(this, config);
    }
});


