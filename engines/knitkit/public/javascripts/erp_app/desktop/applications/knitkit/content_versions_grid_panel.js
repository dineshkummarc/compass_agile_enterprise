Compass.ErpApp.Desktop.Applications.Knitkit.VersionsGridPanel = Ext.extend(Ext.grid.GridPanel, {
    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.Knitkit.VersionsGridPanel.superclass.initComponent.call(this, arguments);
        this.getStore().load();
    },

    constructor : function(config) {
        var overiddenColumns = [
        {
            header:'Version',
            dataIndex:'version',
            sortable:true,
            width:50
        },
        {
            header:'Created',
            dataIndex:'created_at',
            sortable:true,
            renderer: Ext.util.Format.dateRenderer('m/d/Y H:i:s'),
            width:120
        }];

        if(!Compass.ErpApp.Utility.isBlank(config['columns'])){
            overiddenColumns = overiddenColumns.concat(config['columns']);
        }

        overiddenColumns = overiddenColumns.concat([
        {
            menuDisabled:true,
            resizable:false,
            xtype:'actioncolumn',
            header:'View',
            align:'center',
            width:60,
            items:[{
                icon:'/images/icons/document_view/document_view_16x16.png',
                tooltip:'View',
                handler :function(grid, rowIndex, colIndex){
                    var rec = grid.getStore().getAt(rowIndex);
                    grid.viewVersionedContent(rec);
                }
            }]
        },
        {
            menuDisabled:true,
            resizable:false,
            xtype:'actioncolumn',
            header:'Revert',
            align:'center',
            width:60,
            items:[{
                icon:'/images/icons/document_down/document_down_16x16.png',
                tooltip:'Revert',
                handler :function(grid, rowIndex, colIndex){
                    var rec = grid.getStore().getAt(rowIndex);
                    grid.revert(rec);
                }
            }]
        },
        {
            menuDisabled:true,
            resizable:false,
            xtype:'actioncolumn',
            header:'Publish',
            align:'center',
            width:60,
            items:[{
                getClass: function(v, meta, rec) {  // Or return a class from a function
                    if (rec.get('published')) {
                        this.items[0].tooltip = 'Published';
                        return 'published-col';
                    } else {
                        this.items[0].tooltip = 'Publish';
                        return 'publish-col';
                    }
                },
                handler: function(grid, rowIndex, colIndex) {
                    var rec = grid.getStore().getAt(rowIndex);
                    if(rec.get('published')){
                        return false;
                    }
                    else{
                        grid.publish(rec)
                    }
                }
            }]
        }
        ]);

        config['columns'] = overiddenColumns;
        config = Ext.apply({
            bbar: new Ext.PagingToolbar({
                pageSize: 15,
                store: config['store'],
                displayInfo: true,
                displayMsg: '{0} - {1} of {2}',
                emptyMsg: "Empty"
            })
        }, config);

        Compass.ErpApp.Desktop.Applications.Knitkit.VersionsGridPanel.superclass.constructor.call(this, config);
    }
});

Compass.ErpApp.Desktop.Applications.Knitkit.VersionsArticleGridPanel = Ext.extend(Compass.ErpApp.Desktop.Applications.Knitkit.VersionsGridPanel, {
    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.Knitkit.VersionsArticleGridPanel.superclass.initComponent.call(this, arguments);
    },

    viewVersionedContent : function(rec){
        this.initialConfig['centerRegion'].viewContent(rec.get('title') + " - Revision " + rec.get('version'), rec.get('body_html'));
    },

    revert: function(rec){
        var self = this;
        var conn = new Ext.data.Connection();
        conn.request({
            url: './knitkit/versions/revert_content',
            method: 'POST',
            params:{
                id:rec.get('id'),
                version:rec.get('version')
            },
            success: function(response) {
                var obj =  Ext.util.JSON.decode(response.responseText);
                if(obj.success){
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    self.initialConfig['centerRegion'].replaceHtmlInActiveCkEditor(rec.get('body_html'));
                    self.getStore().reload();
                }
                else{
                    Ext.Msg.alert('Error', 'Error reverting');
                    self.initialConfig['centerRegion'].clearWindowStatus();
                }
            },
            failure: function(response) {
                self.initialConfig['centerRegion'].clearWindowStatus();
                Ext.Msg.alert('Error', 'Error reverting');
            }
        });
    },
    
    publish: function(rec){
        var self = this;

        var publishWindow = new Compass.ErpApp.Desktop.Applications.Knitkit.PublishWindow({
            baseParams:{
                id:rec.get('id'),
                site_id:self.initialConfig.siteId,
                version:rec.get('version')
            },
            url:'./knitkit/versions/publish_content',
            listeners:{
                'publish_success':function(window, response){
                    if(response.success){
                        self.initialConfig['centerRegion'].clearWindowStatus();
                        self.getStore().reload();
                    }
                    else{
                        Ext.Msg.alert('Error', 'Error publishing');
                        self.initialConfig['centerRegion'].clearWindowStatus();
                    }
                },
                'publish_failure':function(window, response){
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    Ext.Msg.alert('Error', 'Error publishing');
                }
            }
        });

        publishWindow.show();
    },

    constructor : function(config) {
        config = Ext.apply({
            store: new Ext.data.JsonStore({
                root: 'data',
                totalProperty: 'totalCount',
                baseParams:{
                    id:config['contentId'],
                    site_id:config['siteId']
                },
                idProperty: 'id',
                remoteSort: true,
                fields: [
                {
                    name:'published'
                },
                {
                    name:'id'
                },
                {
                    name:'version'
                },
                {
                    name:'title'
                },
                {
                    name:'excerpt_html'
                },
                {
                    name:'body_html'
                },
                {
                    name:'created_at',
                    type:'date'
                }
                ],
                url:'./knitkit/versions/content_versions'
            })
        }, config);

        Compass.ErpApp.Desktop.Applications.Knitkit.VersionsArticleGridPanel.superclass.constructor.call(this, config);
    }
});


Ext.reg('knitkit_versionsarticlegridpanel', Compass.ErpApp.Desktop.Applications.Knitkit.VersionsArticleGridPanel);

Compass.ErpApp.Desktop.Applications.Knitkit.VersionsBlogGridPanel = Ext.extend(Compass.ErpApp.Desktop.Applications.Knitkit.VersionsGridPanel, {
    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.Knitkit.VersionsBlogGridPanel.superclass.initComponent.call(this, arguments);
    },

    viewVersionedContent : function(rec){
        this.initialConfig['centerRegion'].viewContent(rec.get('title') + " - Revision " + rec.get('version'), rec.get('body_html'));
    },

    revert: function(rec){
        var self = this;
        var conn = new Ext.data.Connection();
        conn.request({
            url: './knitkit/versions/revert_content',
            method: 'POST',
            params:{
                id:rec.get('id'),
                version:rec.get('version')
            },
            success: function(response) {
                var obj =  Ext.util.JSON.decode(response.responseText);
                if(obj.success){
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    self.initialConfig['centerRegion'].replaceHtmlInActiveCkEditor(rec.get('body_html'));
                    self.getStore().reload();
                }
                else{
                    Ext.Msg.alert('Error', 'Error reverting');
                    self.initialConfig['centerRegion'].clearWindowStatus();
                }
            },
            failure: function(response) {
                self.initialConfig['centerRegion'].clearWindowStatus();
                Ext.Msg.alert('Error', 'Error reverting');
            }
        });
    },

    publish: function(rec){
        var self = this;

        var publishWindow = new Compass.ErpApp.Desktop.Applications.Knitkit.PublishWindow({
            baseParams:{
                id:rec.get('id'),
                site_id:self.initialConfig.siteId,
                version:rec.get('version')
            },
            url:'./knitkit/versions/publish_content',
            listeners:{
                'publish_success':function(window, response){
                    if(response.success){
                        self.initialConfig['centerRegion'].clearWindowStatus();
                        self.getStore().reload();
                    }
                    else{
                        Ext.Msg.alert('Error', 'Error publishing');
                        self.initialConfig['centerRegion'].clearWindowStatus();
                    }
                },
                'publish_failure':function(window, response){
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    Ext.Msg.alert('Error', 'Error publishing');
                }
            }
        });

        publishWindow.show();
    },

    constructor : function(config) {
        config = Ext.apply({
            store: new Ext.data.JsonStore({
                root: 'data',
                totalProperty: 'totalCount',
                baseParams:{
                    id:config['contentId'],
                    site_id:config['siteId']
                },
                idProperty: 'id',
                remoteSort: true,
                fields: [
                {
                    name:'id'
                },
                {
                    name:'version'
                },
                {
                    name:'title'
                },
                {
                    name:'excerpt_html'
                },
                {
                    name:'body_html'
                },
                {
                    name:'created_at',
                    type:'date'
                },
                {
                    name:'published'
                }
                ],
                url:'./knitkit/versions/content_versions'
            }),
            columns:[
            {
                menuDisabled:true,
                resizable:false,
                xtype:'actioncolumn',
                header:'Excerpt',
                align:'center',
                width:50,
                items:[{
                    icon:'/images/icons/document_view/document_view_16x16.png',
                    tooltip:'View',
                    handler :function(grid, rowIndex, colIndex){
                        var rec = grid.getStore().getAt(rowIndex);
                        grid.initialConfig['centerRegion'].viewContent(rec.get('title') + " Excerpt - Revision " + rec.get('version'), rec.get('body_html'));
                    }
                }]
            }]
        }, config);

        Compass.ErpApp.Desktop.Applications.Knitkit.VersionsBlogGridPanel.superclass.constructor.call(this, config);
    }
});


Ext.reg('knitkit_versionsbloggridpanel', Compass.ErpApp.Desktop.Applications.Knitkit.VersionsBlogGridPanel);

Compass.ErpApp.Desktop.Applications.Knitkit.VersionsWebsiteSectionGridPanel = Ext.extend(Compass.ErpApp.Desktop.Applications.Knitkit.VersionsGridPanel, {
    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.Knitkit.VersionsWebsiteSectionGridPanel.superclass.initComponent.call(this, arguments);
    },

    viewVersionedContent : function(rec){
        this.initialConfig['centerRegion'].setWindowStatus('Loading template...');
        var self = this;
        var conn = new Ext.data.Connection();
        conn.request({
            url: './knitkit/versions/get_website_section_version',
            method: 'POST',
            params:{
                id:rec.get('id'),
                version:rec.get('version')
            },
            success: function(response) {
                self.initialConfig['centerRegion'].clearWindowStatus();
                var template = response.responseText
                self.initialConfig['centerRegion'].viewSectionLayout(rec.get('title'),template);
            },
            failure: function(response) {
                self.initialConfig['centerRegion'].clearWindowStatus();
                Ext.Msg.alert('Error', 'Error loading tempalte');
            }
        });
    },

    revert: function(rec){
        var self = this;
        var conn = new Ext.data.Connection();
        conn.request({
            url: './knitkit/versions/revert_website_section',
            method: 'POST',
            params:{
                id:rec.get('id'),
                version:rec.get('version')
            },
            success: function(response) {
                var obj =  Ext.util.JSON.decode(response.responseText);
                if(obj.success){
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    self.initialConfig['centerRegion'].replaceContentInActiveCodeMirror(rec.get('body_html'));
                    self.getStore().reload();
                    var conn = new Ext.data.Connection();
                    conn.request({
                        url: './knitkit/versions/get_website_section_version',
                        method: 'POST',
                        params:{
                            id:rec.get('id'),
                            version:rec.get('version')
                        },
                        success: function(response) {
                            var template = response.responseText
                            self.initialConfig['centerRegion'].viewSectionLayout(rec.get('title'),template);
                        },
                        failure: function(response) {
                            self.initialConfig['centerRegion'].clearWindowStatus();
                            Ext.Msg.alert('Error', 'Error loading tempalte');
                        }
                    });
                }
                else{
                    Ext.Msg.alert('Error', 'Error reverting');
                    self.initialConfig['centerRegion'].clearWindowStatus();
                }
            },
            failure: function(response) {
                self.initialConfig['centerRegion'].clearWindowStatus();
                Ext.Msg.alert('Error', 'Error reverting');
            }
        });
    },

    publish: function(rec){
        var self = this;

        var publishWindow = new Compass.ErpApp.Desktop.Applications.Knitkit.PublishWindow({
            baseParams:{
                id:rec.get('id'),
                site_id:self.initialConfig.siteId,
                version:rec.get('version')
            },
            url:'./knitkit/versions/publish_website_section',
            listeners:{
                'publish_success':function(window, response){
                    if(response.success){
                        self.initialConfig['centerRegion'].clearWindowStatus();
                        self.getStore().reload();
                    }
                    else{
                        Ext.Msg.alert('Error', 'Error publishing');
                        self.initialConfig['centerRegion'].clearWindowStatus();
                    }
                },
                'publish_failure':function(window, response){
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    Ext.Msg.alert('Error', 'Error publishing');
                }
            }
        });

        publishWindow.show();
    },

    constructor : function(config) {
        config = Ext.apply({
            store: new Ext.data.JsonStore({
                root: 'data',
                totalProperty: 'totalCount',
                baseParams:{
                    id:config['websiteSectionId'],
                    site_id:config['siteId']
                },
                idProperty: 'id',
                remoteSort: true,
                fields: [
                {
                    name:'id'
                },
                {
                    name:'version'
                },
                {
                    name:'title'
                },
                {
                    name:'created_at',
                    type:'date'
                },
                {
                    name:'published'
                }
                ],
                url:'./knitkit/versions/website_section_layout_versions'
            })
        }, config);

        Compass.ErpApp.Desktop.Applications.Knitkit.VersionsWebsiteSectionGridPanel.superclass.constructor.call(this, config);
    }
});


Ext.reg('knitkit_versionswebsitesectiongridpanel', Compass.ErpApp.Desktop.Applications.Knitkit.VersionsWebsiteSectionGridPanel);


