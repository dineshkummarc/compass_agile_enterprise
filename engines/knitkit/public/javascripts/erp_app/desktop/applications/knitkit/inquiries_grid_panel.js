Compass.ErpApp.Desktop.Applications.Knitkit.InquiriesGridPanel = Ext.extend(Ext.grid.GridPanel, {
    deleteInquiry : function(rec){
        var self = this;
        self.initialConfig['centerRegion'].setWindowStatus('Deleting inquiry...');
        var conn = new Ext.data.Connection();
        conn.request({
            url: './knitkit/inquiries/delete',
            method: 'POST',
            params:{
                id:rec.get("id")
            },
            success: function(response) {
                var obj =  Ext.util.JSON.decode(response.responseText);
                if(obj.success){
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    self.getStore().reload();
                }
                else{
                    Ext.Msg.alert('Error', 'Error deleting inquiry');
                    self.initialConfig['centerRegion'].clearWindowStatus();
                }
            },
            failure: function(response) {
                self.initialConfig['centerRegion'].clearWindowStatus();
                Ext.Msg.alert('Error', 'Error deleting inquiry');
            }
        });


    },

    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.Knitkit.InquiriesGridPanel.superclass.initComponent.call(this, arguments);
        this.getStore().load();
    },

    constructor : function(config) {
        var self = this;
        var store = new Ext.data.JsonStore({
            root: 'inquiries',
            totalProperty: 'totalCount',
            idProperty: 'id',
            remoteSort: true,
            fields: [
            {
                name:'id'
            },
            {
                name:'first_name'
            },
            {
                name:'last_name'
            },
            {
                name:'email'
            },
            {
                name:'created_at'
            },
            {
                name:'inquiry'
            },
            {
                name:'username'
            }
            ],
            url:'./knitkit/inquiries/get/' + config['websiteId']
        });

        config = Ext.apply({
            store:store,
            columns:[
            {
                header:'First Name',
                sortable:true,
                width:150,
                dataIndex:'first_name'
            },
            {
                header:'First Name',
                sortable:true,
                width:150,
                dataIndex:'last_name'
            },
            {
                header:'Email',
                sortable:true,
                width:150,
                dataIndex:'email'
            },
            {
                header:'Created at',
                dataIndex:'created_at',
                width:120,
                sortable:true,
                renderer: Ext.util.Format.dateRenderer('m/d/Y H:i:s')
            },
            {
                menuDisabled:true,
                resizable:false,
                xtype:'actioncolumn',
                header:'View',
                align:'center',
                width:50,
                items:[{
                    icon:'/images/icons/document_view/document_view_16x16.png',
                    tooltip:'View',
                    handler :function(grid, rowIndex, colIndex){
                        var rec = grid.getStore().getAt(rowIndex);
                        self.initialConfig['centerRegion'].showComment(rec.get('inquiry'));
                    }
                }]
            },
            {
                header:'Username',
                sortable:true,
                width:140,
                dataIndex:'username'
            },
            {
                menuDisabled:true,
                resizable:false,
                xtype:'actioncolumn',
                header:'Delete',
                align:'center',
                width:50,
                items:[{
                    icon:'/images/icons/delete/delete_16x16.png',
                    tooltip:'Delete',
                    handler :function(grid, rowIndex, colIndex){
                        var rec = grid.getStore().getAt(rowIndex);
                        self.deleteInquiry(rec);
                    }
                }]
            }
            ],
            bbar: new Ext.PagingToolbar({
                pageSize: 10,
                store: store,
                displayInfo: true,
                displayMsg: '{0} - {1} of {2}',
                emptyMsg: "Empty"
            })
        }, config);

        Compass.ErpApp.Desktop.Applications.Knitkit.InquiriesGridPanel.superclass.constructor.call(this, config);
    }
});

Ext.reg('knitkit_inquiriesgridpanel', Compass.ErpApp.Desktop.Applications.Knitkit.InquiriesGridPanel);
