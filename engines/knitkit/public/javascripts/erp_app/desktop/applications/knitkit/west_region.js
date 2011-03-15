Compass.ErpApp.Desktop.Applications.Knitkit.WestRegion = Ext.extend(Ext.TabPanel, {
    setWindowStatus : function(status){
        this.findParentByType('statuswindow').setStatus(status);
    },
    
    clearWindowStatus : function(){
        this.findParentByType('statuswindow').clearStatus();
    },

    deleteSection : function(id){
        var self = this;
        self.setWindowStatus('Deleting Section...');
        var conn = new Ext.data.Connection();
        conn.request({
            url: './knitkit/section/delete',
            method: 'POST',
            params:{
                id:id
            },
            success: function(response) {
                var obj =  Ext.util.JSON.decode(response.responseText);
                if(obj.success){
                    self.clearWindowStatus();
                    self.sitesTree.getRootNode().reload();
                }
                else{
                    Ext.Msg.alert('Error', 'Error deleting section');
                    self.clearWindowStatus();
                }
            },
            failure: function(response) {
                self.clearWindowStatus();
                Ext.Msg.alert('Error', 'Error deleting section');
            }
        });
    },

    deleteSite : function(id){
        var self = this;
        self.setWindowStatus('Deleting site...');
        var conn = new Ext.data.Connection();
        conn.request({
            url: './knitkit/site/delete',
            method: 'POST',
            params:{
                id:id
            },
            success: function(response) {
                var obj =  Ext.util.JSON.decode(response.responseText);
                if(obj.success){
                    self.clearWindowStatus();
                    self.sitesTree.getRootNode().reload();
                }
                else{
                    Ext.Msg.alert('Error', 'Error deleting site');
                    self.clearWindowStatus();
                }
            },
            failure: function(response) {
                self.clearWindowStatus();
                Ext.Msg.alert('Error', 'Error deleting site');
            }
        });
    },

    publish : function(node){
        var self = this;
        var publishWindow = new Compass.ErpApp.Desktop.Applications.Knitkit.PublishWindow({
            baseParams:{
                id:node.id.split('_')[1]
            },
            url:'./knitkit/site/publish',
            listeners:{
                'publish_success':function(window, response){
                    if(response.success){
                        self.clearWindowStatus();
                        self.getPublications(node);
                    }
                    else{
                        Ext.Msg.alert('Error', 'Error publishing site');
                        self.clearWindowStatus();
                    }
                },
                'publish_failure':function(window, response){
                    self.clearWindowStatus();
                    Ext.Msg.alert('Error', 'Error publishing site');
                }
            }
        });

        publishWindow.show();
    },

    editSectionLayout : function(sectionName, sectionId){
        var self = this;
        self.setWindowStatus('Loading section template...');
        var conn = new Ext.data.Connection();
        conn.request({
            url: './knitkit/section/get_layout',
            method: 'POST',
            params:{
                id:sectionId
            },
            success: function(response) {
                self.initialConfig['centerRegion'].editSectionLayout(
                    sectionName,
                    sectionId,
                    response.responseText,
                    [{
                        text: 'Insert Content Area',
                        handler: function(btn){
                            var codeMirror = btn.findParentByType('codemirror');
                            Ext.MessageBox.prompt('New File', 'Please enter content area name:', function(btn, text){
                                if(btn == 'ok'){
                                    codeMirror.setValue(codeMirror.getValue() + '<%=render_content(:'+text+')%>');
                                }
                            });
                        }
                    }]);
                self.clearWindowStatus();
            },
            failure: function(response) {
                self.clearWindowStatus();
                Ext.Msg.alert('Error', 'Error loading section layout.');
            }
        });
    },

    changeSecurityOnSection : function(node, secure){
        var self = this;
        self.setWindowStatus('Loading securing section...');
        var conn = new Ext.data.Connection();
        conn.request({
            url: './knitkit/section/update_security',
            method: 'POST',
            params:{
                id:node.id.split('_')[1],
                site_id:node.attributes.siteId,
                secure:secure
            },
            success: function(response) {
                var obj = Ext.util.JSON.decode(response.responseText);
                if(obj.success){
                    self.clearWindowStatus();
                    self.sitesTree.getRootNode().reload();
                }
                else{
                    Ext.Msg.alert('Error', 'Error securing section');
                }
            },
            failure: function(response) {
                self.clearWindowStatus();
                Ext.Msg.alert('Error', 'Error securing section.');
            }
        });
    },

    initComponent: function() {
        var self = this;
        this.sitesTree = new Ext.tree.TreePanel({
            dataUrl:'./knitkit/websites',
            root:{
                nodeType: 'async'
            },
            region: 'center',
            rootVisible:false,
            listeners:{
                'contextmenu':function(node, e){
                    e.stopEvent();
                    var items = [];

                    items.push({
                        text:'View In Web Navigator',
                        iconCls:'icon-globe',
                        listeners:{
                            'click':function(){
                                var webNavigator = CompassDesktop.getModules().find("id == 'web-navigator-win'");
                                webNavigator.createWindow(node.attributes['url']);
                            }
                        }
                    });
					
                    if(node.attributes['canAddSections']){
                        items.push({
                            text:'Add Section',
                            iconCls:'icon-add',
                            listeners:{
                                'click':function(){
                                    var addSectionWindow = new Ext.Window({
                                        layout:'fit',
                                        width:375,
                                        title:'New Section',
                                        height:125,
                                        plain: true,
                                        buttonAlign:'center',
                                        items: new Ext.FormPanel({
                                            labelWidth: 110,
                                            frame:false,
                                            bodyStyle:'padding:5px 5px 0',
                                            url:'./knitkit/section/new',
                                            defaults: {
                                                width: 225
                                            },
                                            items: [
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Title',
                                                allowBlank:false,
                                                name:'title'
                                            },
                                            {
                                                width: 100,
                                                xtype: 'combo',
                                                forceSelection:true,
                                                store: [
                                                ['Page','Page'],
                                                ['Blog','Blog'],
                                                ],
                                                value:'Page',
                                                fieldLabel: 'Type',
                                                name: 'type',
                                                allowBlank: false,
                                                triggerAction: 'all'
                                            },
                                            {
                                                xtype:'hidden',
                                                name:'node_id',
                                                value:node.id
                                            }
                                            ]
                                        }),
                                        buttons: [{
                                            text:'Submit',
                                            listeners:{
                                                'click':function(button){
                                                    var window = button.findParentByType('window');
                                                    var formPanel = window.findByType('form')[0];
                                                    self.setWindowStatus('Creating section...');
                                                    formPanel.getForm().submit({
                                                        reset:true,
                                                        success:function(form, action){
                                                            self.clearWindowStatus();
                                                            var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                            if(obj.success){
                                                                self.sitesTree.getRootNode().reload();
                                                            }
                                                            else{
                                                                Ext.Msg.alert("Error", obj.msg);
                                                            }
                                                        },
                                                        failure:function(form, action){
                                                            self.clearWindowStatus();
                                                            var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                            Ext.Msg.alert("Error", obj.msg);
                                                        }
                                                    });
                                                }
                                            }
                                        },{
                                            text: 'Close',
                                            handler: function(){
                                                addSectionWindow.close();
                                            }
                                        }]
                                    });
                                    addSectionWindow.show();
                                }
                            }
                        });
                    }

                    if(node.attributes['isSection']){
                        items.push({
                            text:'View Articles',
                            iconCls:'icon-document',
                            listeners:{
                                'click':function(){
                                    self.getArticles(node);
                                }
                            }
                        });

                        if(node.attributes.isSecured){
                            items.push({
                                text:'Unsecure',
                                iconCls:'icon-document',
                                listeners:{
                                    'click':function(){
                                        self.changeSecurityOnSection(node, false);
                                    }
                                }
                            });
                        }
                        else{
                            items.push({
                                text:'Secure',
                                iconCls:'icon-document_lock',
                                listeners:{
                                    'click':function(){
                                        self.changeSecurityOnSection(node, true);
                                    }
                                }
                            });
                        }


                        //no layouts for blogs.
                        if(Compass.ErpApp.Utility.isBlank(node.attributes['isBlog']) && node.attributes['hasLayout']){
                            items.push({
                                text:'Edit Layout',
                                iconCls:'icon-edit',
                                listeners:{
                                    'click':function(){
                                        self.editSectionLayout(node.text, node.id.split('_')[1]);
                                    }
                                }
                            });
                        }
                        else
                        if(Compass.ErpApp.Utility.isBlank(node.attributes['isBlog'])){
                            items.push({
                                text:'Add Layout',
                                iconCls:'icon-add',
                                listeners:{
                                    'click':function(){
                                        var sectionId = node.id.split('_')[1];
                                        var conn = new Ext.data.Connection();
                                        conn.request({
                                            url: './knitkit/section/add_layout',
                                            method: 'POST',
                                            params:{
                                                id:sectionId
                                            },
                                            success: function(response) {
                                                var obj =  Ext.util.JSON.decode(response.responseText);
                                                if(obj.success){
                                                    self.clearWindowStatus();
                                                    self.sitesTree.getRootNode().reload();
                                                    self.editSectionLayout(node.text, sectionId);
                                                }
                                                else
                                                {
                                                    self.clearWindowStatus();
                                                    Ext.Msg.alert('Status', obj.message);
                                                }
                                            },
                                            failure: function(response) {
                                                self.clearWindowStatus();
                                                Ext.Msg.alert('Status', 'Error adding layout.');
                                            }
                                        });
                                    }
                                }
                            });
                        }

                        items.push({
                            text:'Delete ' + node.attributes["type"],
                            iconCls:'icon-delete',
                            listeners:{
                                'click':function(){
                                    self.deleteSection(node.id.split('_')[1]);
                                }
                            }
                        });
                    }
                    else{
                        items.push({
                            text:'Publish',
                            iconCls:'icon-document_up',
                            listeners:{
                                'click':function(){
                                    self.publish(node);
                                }
                            }
                        });

                        items.push({
                            text:'Publications',
                            iconCls:'icon-documents',
                            listeners:{
                                'click':function(){
                                    self.getPublications(node);
                                }
                            }
                        });

                        items.push({
                            text:'Edit Site',
                            iconCls:'icon-edit',
                            listeners:{
                                'click':function(){
                                    var editWebsiteWindow = new Ext.Window({
                                        layout:'fit',
                                        width:375,
                                        title:'Edit Website',
                                        height:210,
                                        plain: true,
                                        buttonAlign:'center',
                                        items: new Ext.FormPanel({
                                            labelWidth: 110,
                                            frame:false,
                                            bodyStyle:'padding:5px 5px 0',
                                            url:'./knitkit/site/update',
                                            defaults: {
                                                width: 225
                                            },
                                            items: [
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Name',
                                                allowBlank:false,
                                                name:'name',
                                                value:node.attributes['name']
                                            },
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Host',
                                                allowBlank:false,
                                                name:'host',
                                                value:node.attributes['host']
                                            },
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Title',
                                                allowBlank:false,
                                                name:'title',
                                                value:node.attributes['title']
                                            },
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Sub Title',
                                                allowBlank:false,
                                                name:'subtitle',
                                                value:node.attributes['subtitle']

                                            },
                                            {
                                                xtype:'textfield',
                                                fieldLabel:'Email',
                                                allowBlank:false,
                                                name:'email',
                                                value:node.attributes['email']
                                            },
                                            {
                                                xtype:'hidden',
                                                name:'id',
                                                value:node.attributes.id.split('_')[1]
                                            }
                                            ]
                                        }),
                                        buttons: [{
                                            text:'Submit',
                                            listeners:{
                                                'click':function(button){
                                                    var window = button.findParentByType('window');
                                                    var formPanel = window.findByType('form')[0];
                                                    self.setWindowStatus('Updating website...');
                                                    formPanel.getForm().submit({
                                                        reset:true,
                                                        success:function(form, action){
                                                            self.clearWindowStatus();
                                                            editWebsiteWindow.close();
                                                            self.sitesTree.getRootNode().reload();
                                                        },
                                                        failure:function(form, action){
                                                            self.clearWindowStatus();
                                                            Ext.Msg.alert("Error", "Error updating website");
                                                        }
                                                    });
                                                }
                                            }
                                        },{
                                            text: 'Close',
                                            handler: function(){
                                                editWebsiteWindow.close();
                                            }
                                        }]
                                    });
                                    editWebsiteWindow.show();
                                }
                            }
                        });

                        items.push({
                            text:'Delete',
                            iconCls:'icon-delete',
                            listeners:{
                                'click':function(){
                                    self.deleteSite(node.id.split('_')[1]);
                                }
                            }
                        });
                    }

                    var contextMenu = new Ext.menu.Menu({
                        items:items
                    });
                    contextMenu.showAt(e.xy);
                }
            }
        });

        this.contentsCardPanel = new Ext.Panel({
            layout:'card',
            region:'south',
            autoDestroy:true,
            split:true,
            height:300,
            collapsible:true
        });

        var layout = new Ext.Panel({
            layout: 'border',
            autoDestroy:true,
            title:'Websites',
            items: [this.sitesTree,this.contentsCardPanel],
            tbar:{
                items:[
                {
                    text:'New Site',
                    iconCls:'icon-add',
                    handler:function(btn){
                        var addWebsiteWindow = new Ext.Window({
                            layout:'fit',
                            width:375,
                            title:'New Website',
                            height:210,
                            plain: true,
                            buttonAlign:'center',
                            items: new Ext.FormPanel({
                                labelWidth: 110,
                                frame:false,
                                bodyStyle:'padding:5px 5px 0',
                                url:'./knitkit/site/new',
                                defaults: {
                                    width: 225
                                },
                                items: [
                                {
                                    xtype:'textfield',
                                    fieldLabel:'Name',
                                    allowBlank:false,
                                    name:'name'
                                },
                                {
                                    xtype:'textfield',
                                    fieldLabel:'Host',
                                    allowBlank:false,
                                    name:'host'
                                },
                                {
                                    xtype:'textfield',
                                    fieldLabel:'Title',
                                    allowBlank:false,
                                    name:'title'
                                },
                                {
                                    xtype:'textfield',
                                    fieldLabel:'Sub Title',
                                    allowBlank:false,
                                    name:'subtitle'
                                },
                                {
                                    xtype:'textfield',
                                    fieldLabel:'Email',
                                    allowBlank:false,
                                    name:'email'
                                }
                                ]
                            }),
                            buttons: [{
                                text:'Submit',
                                listeners:{
                                    'click':function(button){
                                        var window = button.findParentByType('window');
                                        var formPanel = window.findByType('form')[0];
                                        self.setWindowStatus('Creating website...');
                                        formPanel.getForm().submit({
                                            reset:true,
                                            success:function(form, action){
                                                self.clearWindowStatus();
                                                var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                if(obj.success){
                                                    self.sitesTree.getRootNode().reload();
                                                }
                                            },
                                            failure:function(form, action){
                                                self.clearWindowStatus();
                                                Ext.Msg.alert("Error", "Error creating website");
                                            }
                                        });
                                    }
                                }
                            },{
                                text: 'Close',
                                handler: function(){
                                    addWebsiteWindow.close();
                                }
                            }]
                        });
                        addWebsiteWindow.show();
                    }
                }
                ]
            }
        });

        this.items = [layout, {
            xtype:'knitkit_themestreepanel',
            centerRegion:this.initialConfig['module'].centerRegion
        }];
        
        Compass.ErpApp.Desktop.Applications.Knitkit.WestRegion.superclass.initComponent.call(this, arguments);
        
        this.setActiveTab(0);
    },

    getArticles : function(node){
        this.contentsCardPanel.removeAll(true);
        var xtype = 'knitkit_'+node.attributes.type.toLowerCase()+'articlesgridpanel';
        this.contentsCardPanel.add({
            xtype:xtype,
            title:node.attributes.siteName + ' - ' + node.attributes.text + ' - Articles',
            sectionId:node.id.split('_')[1],
            centerRegion:this.initialConfig['module'].centerRegion,
            siteId:node.attributes.siteId
        });
        this.contentsCardPanel.getLayout().setActiveItem(this.contentsCardPanel.items.length - 1);
    },

    getPublications : function(node){
        this.contentsCardPanel.removeAll(true);
        this.contentsCardPanel.add({
            xtype:'knitkit_publishedgridpanel',
            title:node.attributes.siteName + ' Publications',
            siteId:node.id.split('_')[1],
            centerRegion:this.initialConfig['module'].centerRegion
        });
        this.contentsCardPanel.getLayout().setActiveItem(this.contentsCardPanel.items.length - 1);
    },

    constructor : function(config) {
        config = Ext.apply({
            region:'west',
            split:true,
            width:350,
            collapsible:true
        }, config);

        Compass.ErpApp.Desktop.Applications.Knitkit.WestRegion.superclass.constructor.call(this, config);
    }
});

Ext.reg('knitkit_westregion', Compass.ErpApp.Desktop.Applications.Knitkit.WestRegion);
