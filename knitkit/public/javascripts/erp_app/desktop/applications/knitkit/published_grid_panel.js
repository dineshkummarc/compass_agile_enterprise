Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.PublishedGridPanel",{
    extend:"Ext.grid.Panel",
    alias:'widget.knitkit_publishedgridpanel',
    initComponent: function() {
        this.callParent(arguments);
        this.getStore().load();
    },

    activate : function(rec){
        var self = this;
        var conn = new Ext.data.Connection();
        conn.request({
            url: '/knitkit/erp_app/desktop/site/activate_publication',
            method: 'POST',
            params:{
                id:self.initialConfig.siteId,
                version:rec.get('version')
            },
            success: function(response) {
                var obj =  Ext.decode(response.responseText);
                if(obj.success){
                    self.getStore().load();
                }
                else{
                    Ext.Msg.alert('Error', 'Error activating publication');
                }
            },
            failure: function(response) {
                Ext.Msg.alert('Error', 'Error activating publication');
            }
        });
    },

    setViewingVersion : function(rec){
        var self = this;
        var conn = new Ext.data.Connection();
        conn.request({
            url: '/knitkit/erp_app/desktop/site/set_viewing_version',
            method: 'POST',
            params:{
                id:self.initialConfig.siteId,
                version:rec.get('version')
            },
            success: function(response) {
                var obj =  Ext.decode(response.responseText);
                if(obj.success){
                    self.getStore().load();
                }
                else{
                    Ext.Msg.alert('Error', 'Error setting viewing version');
                }
            },
            failure: function(response) {
                Ext.Msg.alert('Error', 'Error setting viewing version');
            }
        });
    },

    constructor : function(config) {
        var store = Ext.create("Ext.data.Store",{
            proxy:{
                type:'ajax',
                url:'/knitkit/erp_app/desktop/site/website_publications',
                reader:{
                    type:'json',
                    root:'data'
                },
                extraParams:{id:config['siteId']}
            },
            idProperty: 'id',
            remoteSort: true,
            fields: [
            {
                name:'id'
            },
            {
                name:'version',
                type: 'float'
            },
            {
                name:'created_at',
                type: 'date'
            },
            {
                name:'comment'
            },
            {
                name:'active',
                type:'boolean'
            },
            {
                name:'viewing',
                type:'boolean'
            }
            ],
            listeners:{
                'exception':function(proxy, type, action, options, response, arg){
                    Ext.Msg.alert('Error',arg);
                }
            }
        });

        config = Ext.apply({
            store:store,
            columns: [
            {
                header: "Version",
                sortable:true,
                width: 60,
                dataIndex: 'version'
            },
            {
                header: "Published",
                width: 130,
                sortable:true,
                renderer: Ext.util.Format.dateRenderer('m/d/Y H:i:s'),
                dataIndex: 'created_at'
            },
            {
                menuDisabled:true,
                resizable:false,
                xtype:'actioncolumn',
                header:'Viewing',
                align:'center',
                width:50,
                items:[{
                    getClass: function(v, meta, rec) {  // Or return a class from a function
                        if (rec.get('viewing')) {
                            this.items[0].tooltip = 'Viewing';
                            return 'viewing-col';
                        } else {
                            this.items[0].tooltip = 'View';
                            return 'view-col';
                        }
                    },
                    handler: function(grid, rowIndex, colIndex) {
                        var rec = grid.getStore().getAt(rowIndex);
                        if(rec.get('viewing')){
                            return false;
                        }
                        else{
                            grid.ownerCt.setViewingVersion(rec)
                        }
                    }
                }]
            },
            {
                menuDisabled:true,
                resizable:false,
                xtype:'actioncolumn',
                header:'Active',
                align:'center',
                width:50,
                items:[{
                    getClass: function(v, meta, rec) {  // Or return a class from a function
                        if (rec.get('active')) {
                            this.items[0].tooltip = 'Active';
                            return 'active-col';
                        } else {
                            this.items[0].tooltip = 'Activate';
                            return 'activate-col';
                        }
                    },
                    handler: function(grid, rowIndex, colIndex) {
                        if(ErpApp.Authentication.RoleManager.hasRole(['admin','publisher'])){
                            var rec = grid.getStore().getAt(rowIndex);
                            if(rec.get('active')){
                                return false;
                            }
                            else{
                                grid.ownerCt.activate(rec)
                            }
                        }
                        else{
                            ErpApp.Authentication.RoleManager.invalidRole({});
                        }
                    }
                }]
            },
            {
                menuDisabled:true,
                resizable:false,
                xtype:'actioncolumn',
                header:'Note',
                align:'center',
                width:40,
                items:[{
                    getClass: function(v, meta, rec) {  // Or return a class from a function
                        this.items[0].tooltip = rec.get('comment');
                        return 'info-col';
                    },
                    handler: function(grid, rowIndex, colIndex) {
                        return false;
                    }
                }]
            },
            ],
            bbar: new Ext.PagingToolbar({
                pageSize: 9,
                store:store,
                displayInfo: true,
                displayMsg: '{0} - {1} of {2}',
                emptyMsg: "Empty"
            })
        }, config);

        this.callParent([config]);
    }
});