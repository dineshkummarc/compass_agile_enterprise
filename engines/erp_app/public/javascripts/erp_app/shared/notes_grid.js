Ext.define("Compass.ErpApp.Shared.NotesGrid",{
    extend:"Ext.grid.Panel",
    alias:'widget.shared_notesgrid',

    deleteNote : function(rec){
        var self = this;
        var conn = new Ext.data.Connection();
        conn.request({
            url: '/erp_app/shared/notes/delete/',
            params:{
                id:rec.get('id')
            },
            method: 'POST',
            success: function(response) {
                var obj =  Ext.decode(response.responseText);
                if(obj.success){
                    self.getStore().load();
                }
                else{
                    Ext.Msg.alert('Error', 'Error deleting note.');
                }
            },
            failure: function(response) {
                Ext.Msg.alert('Error', 'Error deleting note.');
            }
        });
    },

    updateParty : function(partyId){
        this.partyId = partyId;
        this.store.proxy.url = '/erp_app/shared/notes/view/'+this.partyId;
        this.store.load();
    },

    initComponent: function() {
        this.store.load();
        Compass.ErpApp.Shared.NotesGrid.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        var self = this;
        this.partyId = config['partyId'];

        var noteTypeStore = Ext.create('Ext.data.Store', {
            proxy: {
                type: 'ajax',
                url : '/erp_app/shared/notes/note_types/',
                reader: {
                    type: 'json',
                    root: 'note_types'
                }
            },
            fields:[
            {
                name: 'id',
                type: 'int'
            },
            {
                name: 'description',
                type: 'string'
            }
            ]
        });

        var notesStore = Ext.create('Ext.data.Store', {
            proxy: {
                type: 'ajax',
                url : '/erp_app/shared/notes/view/'+self.partyId,
                reader: {
                    type: 'json',
                    root: 'notes'
                }
            },
            remoteSort:true,
            fields:[
            {
                name: 'id',
                type: 'int'
            },
            {
                name: 'note_type_desc',
                type: 'string'
            },
            {
                name: 'summary',
                type: 'string'
            },
            {
                name: 'content',
                type: 'string'
            },
            {
                name:'created_by_login',
                type:'string'
            },
            {
                name:'created_at',
                type:'date'
            }
            ]
        });

        var columns = [{
            header:'Note Type',
            dataIndex:'note_type_desc',
            width:150
        },
        {
            header:'Summary',
            dataIndex:'summary',
            width:130
        },
        {
            header:'Created By',
            dataIndex:'created_by_login',
            width:100
        },
        {
            header:'Created',
            dataIndex:'created_at',
            sortable:true,
            renderer: Ext.util.Format.dateRenderer('m/d/Y H:i:s'),
            width:120
        },
        {
            menuDisabled:true,
            resizable:false,
            xtype:'actioncolumn',
            align:'center',
            width:50,
            items:[{
                icon:'/images/icons/document_view/document_view_16x16.png',
                tooltip:'View',
                handler :function(grid, rowIndex, colIndex){
                    var rec = grid.getStore().getAt(rowIndex);
                    var noteWindow = Ext.create("Ext.window.Window",{
                        width:325,
                        height:400,
                        buttonAlign:'center',
                        autoScroll:true,
                        layout:'fit',
                        items:{
                            xtype:'panel',
                            html:rec.get('content')
                        },
                        buttons: [{
                            text: 'Close',
                            handler: function(){
                                noteWindow.close();
                            }
                        }]
                    });
                    noteWindow.show();
                }
            }]
        },
        {
            menuDisabled:true,
            resizable:false,
            xtype:'actioncolumn',
            align:'center',
            width:50,
            items:[{
                icon:'/images/icons/delete/delete_16x16.png',
                tooltip:'Delete',
                handler :function(grid, rowIndex, colIndex){
                    Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this note?', function(btn){
                        if(btn == 'no'){
                            return false;
                        }
                        else
                        if(btn == 'yes')
                        {
                            var rec = grid.getStore().getAt(rowIndex);
                            self.deleteNote(rec);
                        }
                    });
                }
            }]
        }];

        var toolBarItems = []
        toolBarItems.push( {
            text:'Add Note',
            iconCls:'icon-add',
            handler:function(){
                var addNoteWindow = Ext.create("Ext.window.Window",{
                    layout:'fit',
                    width:325,
                    title:'New Note',
                    height:450,
                    plain: true,
                    buttonAlign:'center',
                    items: new Ext.FormPanel({
                        frame:false,
                        layout:'',
                        bodyStyle:'padding:5px 5px 0',
                        url:'/erp_app/shared/notes/create/'+self.partyId,
                        items: [
                        {
                            emptyText:'Select Type...',
                            xtype: 'combo',
                            labelAlign:'top',
                            forceSelection:true,
                            store: noteTypeStore,
                            displayField:'description',
                            valueField:'id',
                            fieldLabel: 'Note Type',
                            name: 'note_type_id',
                            allowBlank: false,
                            triggerAction: 'all'
                        },
                        {
                            xtype : 'label',
                            html : 'Note:',
                            cls : "x-form-item x-form-item-label card-label"
                        },
                        {
                            xtype: 'textarea',
                            allowBlank:false,
                            height:300,
                            width:300,
                            name:'content'
                        }
                        ]
                    }),
                    buttons: [{
                        text:'Submit',
                        listeners:{
                            'click':function(button){
                                var window = button.findParentByType('window');
                                var formPanel = window.query('.form')[0];
                                formPanel.getForm().submit({
                                    reset:true,
                                    success:function(form, action){
                                        var obj = Ext.decode(action.response.responseText);
                                        if(obj.success){
                                            self.getStore().load();
                                            addNoteWindow.close();
                                        }
                                        else{
                                            Ext.Msg.alert("Error", obj.message);
                                        }
                                    },
                                    failure:function(form, action){
                                        if(action.response !== undefined){
                                            var obj =  Ext.decode(action.response.responseText);
                                            Ext.Msg.alert("Error", obj.message);
                                        }
                                        else{
                                            Ext.Msg.alert("Error", 'Error adding note.');
                                        }
                                    }
                                });
                            }
                        }
                    },{
                        text: 'Close',
                        handler: function(){
                            addNoteWindow.close();
                        }
                    }]
                });
                addNoteWindow.show();
            }
        });
     
        //toolBarItems.push('|');
        //add note type drop down

        config = Ext.apply({
            region:'west',
            store:notesStore,
            loadMask:false,
            columns:columns,
            tbar:{
                items:toolBarItems
            },
            bbar: Ext.create("Ext.PagingToolbar",{
                pageSize: 30,
                store: notesStore,
                displayInfo: true,
                displayMsg: 'Displaying {0} - {1} of {2}',
                emptyMsg: "No Notes"
            })
        }, config);

        Compass.ErpApp.Shared.NotesGrid.superclass.constructor.call(this, config);
    }
});


