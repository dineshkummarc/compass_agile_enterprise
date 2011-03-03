Compass.ErpApp.Desktop.Applications.Knitkit.SiteVersionsGridPanel = Ext.extend(Ext.grid.GridPanel, {
    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.Knitkit.SiteVersionsGridPanel.superclass.initComponent.call(this, arguments);
        this.getStore().load();
    },

    activate : function(rec){
        var self = this;
        var conn = new Ext.data.Connection();
        conn.request({
            url: './knitkit/site/activate_publication',
            method: 'POST',
            params:{
                site_id:self.initialConfig.siteId,
                version:rec.get('version')
            },
            success: function(response) {
                var obj =  Ext.util.JSON.decode(response.responseText);
                if(obj.success){
                    self.getStore().reload();
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

    constructor : function(config) {
        var expander = new Ext.ux.grid.RowExpander({
            tpl : new Ext.Template('<p><b>Comment:</b> {comment}</p><br>')
        });

        var store = new Ext.data.JsonStore({
            root: 'data',
            totalProperty: 'totalCount',
            baseParams:{
                site_id:config['siteId']
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
            }
            ],
            url:'./knitkit/site/site_publications',
            listeners:{
                'exception':function(proxy, type, action, options, response, arg){
                    Ext.Msg.alert('Error',arg);
                }
            }
        });

        config = Ext.apply({
            store:store,
            plugins: expander,
            columns: [
            expander,
            {
                header: "Version",
                sortable:true,
                width: 120,
                dataIndex: 'version'
            },
            {
                header: "Published",
                width: 150,
                sortable:true,
                renderer: Ext.util.Format.dateRenderer('m/d/Y H:i:s'),
                dataIndex: 'created_at'
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
                        var rec = grid.getStore().getAt(rowIndex);
                        if(rec.get('active')){
                            return false;
                        }
                        else{
                            grid.activate(rec)
                        }
                    }
                }]
            }
            ],
            bbar: new Ext.PagingToolbar({
                pageSize: 9,
                store:store,
                displayInfo: true,
                displayMsg: '{0} - {1} of {2}',
                emptyMsg: "Empty"
            })
        }, config);

        Compass.ErpApp.Desktop.Applications.Knitkit.SiteVersionsGridPanel.superclass.constructor.call(this, config);
    }
});

Ext.reg('knitkit_siteversionsgridpanel', Compass.ErpApp.Desktop.Applications.Knitkit.SiteVersionsGridPanel);

