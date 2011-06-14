
Compass.ErpApp.Organizer.Applications.Crm.PartyGrid = Ext.extend(Ext.grid.GridPanel, {
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
        var messageBox = null;

        var proxy = new Ext.data.HttpProxy({
            url:this.initialConfig['url'] || './crm/parties'
        });

        proxy.addListener('exception', function(proxy, type, action, options, res) {
            var message = 'Error in processing request';

            if(res.message != null)
                message = res.message;

            Ext.Msg.alert('Error', message);
        });

        proxy.addListener('beforewrite', function(proxy, action) {
            if(messageBox != null)
                messageBox.hide();

            var messageBox = Ext.Msg.wait('Status', 'Sending request...');
        });

        proxy.addListener('write', function(dataProxy, action, data, response, rs, options) {
            if(messageBox != null)
                messageBox.hide();

            rs.dirty = false;
            rs.commit();
            grid.getStore().reload();
            Ext.Msg.alert('Status', response.message);
        });

        var reader = new Ext.data.JsonReader({
            successProperty: 'success',
            idProperty: 'business_party.id',
            root: 'data',
            totalProperty:'totalCount',
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
                party_name:null,
                party_type:this.initialConfig['partyType']
            },
            listeners:{
                'exception':function(){
                    Ext.Msg.alert("Error", arguments[5]);
                }
            }
        });

        this.store = store;
        
        var toolBar = new Ext.Toolbar({
            items:[
            '<span style="color:white;font-weight:bold;">'+ this.initialConfig['partyType'] +' Name:</span>',
            {
                xtype:'textfield',
                width:150
            },
            {
                xtype:'tbbutton',
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
                iconCls: 'icon-add',
                handler: function(button) {
                    grid.fireEvent('addpartybtnclick', this, grid);
                }
            },
            '|',
            {
                text: 'Delete',
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
        })

        this.tbar = toolBar;

        this.bbar = new Ext.PagingToolbar({
            pageSize: 30,
            store: store,
            displayInfo: true,
            displayMsg: 'Displaying {0} - {1} of {2}',
            emptyMsg: "No Parties"
        });

        this.store.load();

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

        var editor = new Ext.ux.grid.RowEditor({
            saveText: 'Update',
            buttonAlign:'center',
            RowEditor:true,
            errorSummary:false
        });

        config = Ext.apply({
            columns:columns,
            fields:fields,
            layout:'fit',
            frame: false,
            autoScroll:true,
            region:'center',
            plugins:[editor],
            loadMask:true
        }, config);
        Compass.ErpApp.Organizer.Applications.Crm.PartyGrid.superclass.constructor.call(this, config);
    }
});

Ext.reg('partygrid', Compass.ErpApp.Organizer.Applications.Crm.PartyGrid);


