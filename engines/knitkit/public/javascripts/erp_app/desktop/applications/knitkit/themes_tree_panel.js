Ext.define("Compass.ErpApp.Desktop.Applications.ThemesTreePanel",{
    extend:"Compass.ErpApp.Shared.FileManagerTree",
    alias:'widget.knitkit_themestreepanel',
    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.ThemesTreePanel.superclass.initComponent.call(this, arguments);
    },

    updateThemeActiveStatus : function(themeId, siteId, active){
        var self = this;
        self.initialConfig['centerRegion'].setWindowStatus('Updating Status...');
        var conn = new Ext.data.Connection();
        conn.request({
            url: './knitkit/theme/change_status',
            method: 'POST',
            params:{
                id:themeId,
                site_id:siteId,
                active:active
            },
            success: function(response) {
                var obj =  Ext.decode(response.responseText);
                if(obj.success){
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    self.getStore().load({node:self.getRootNode()});
                }
                else{
                    Ext.Msg.alert('Error', 'Error updating status');
                    self.initialConfig['centerRegion'].clearWindowStatus();
                }
            },
            failure: function(response) {
                self.initialConfig['centerRegion'].clearWindowStatus();
                Ext.Msg.alert('Error', 'Error updating status');
            }
        });
    },

    deleteTheme : function(themeId){
        var self = this;
        self.initialConfig['centerRegion'].setWindowStatus('Deleting theme...');
        var conn = new Ext.data.Connection();
        conn.request({
            url: './knitkit/theme/delete',
            method: 'POST',
            params:{
                id:themeId
            },
            success: function(response) {
                var obj =  Ext.decode(response.responseText);
                if(obj.success){
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    self.getStore().load({node:self.getRootNode()});
                }
                else{
                    Ext.Msg.alert('Error', 'Error deleting theme');
                    self.initialConfig['centerRegion'].clearWindowStatus();
                }
            },
            failure: function(response) {
                self.initialConfig['centerRegion'].clearWindowStatus();
                Ext.Msg.alert('Error', 'Error deleting theme');
            }
        });
    },

    exportTheme : function(themeId){
        var self = this;
        self.initialConfig['centerRegion'].setWindowStatus('Exporting theme...');
        window.open('/erp_app/desktop/knitkit/theme/export?id='+themeId,'mywindow','width=400,height=200');
        self.initialConfig['centerRegion'].clearWindowStatus();
    },
  
    constructor : function(config) {
        var sitesJsonStore = Ext.create("Ext.data.Store",{
            proxy:{
                url:'./knitkit/site/index',
                type:'ajax',
                reader:{
                    type:'json',
                    root:'sites'
                }
            },
            fields: [
            {
                name:'name'
            },
            {
                name:'id'
            }
            ]
        });

        var self = this;

        config = Ext.apply({
            title:'Themes',
            controllerPath:'./knitkit/theme',
            autoDestroy:true,
            allowDownload:true,
            addViewContentsToContextMenu:true,
            rootVisible:false,
            standardUploadUrl:'./knitkit/theme/upload_file',
            xhrUploadUrl:'./knitkit/theme/upload_file',
            url:'./knitkit/theme/index',
            fields:[
                {name:'isTheme'},
                {name:'isActive'},
                {name:'siteId'},
                {name:'text'},
                {name:'id'},
                {name:'leaf'},
                {name:'handleContextMenu'},
                {name:'contextMenuDisabled'}
            ],
            containerScroll: true,
            listeners:{
                'contentLoaded':function(fileManager, node, content){
                    self.initialConfig['centerRegion'].editTemplateFile(node, content, []);
                },
                'handleContextMenu':function(fileManager, node, e){
                    if(node.data['isTheme']){
                        var items = [];
                        if(node.data['isActive']){
                            items.push({
                                text:'Deactivate',
                                iconCls:'icon-delete',
                                listeners:{
                                    'click':function(){
                                        self.updateThemeActiveStatus(node.data.id, node.data['siteId'], false);
                                    }
                                }
                            });
                        }
                        else{
                            items.push({
                                text:'Activate',
                                iconCls:'icon-add',
                                listeners:{
                                    'click':function(){
                                        self.updateThemeActiveStatus(node.data.id, node.data['siteId'], true);
                                    }
                                }
                            });
                        }
                        items.push({
                            text:'Delete Theme',
                            iconCls:'icon-delete',
                            listeners:{
                                'click':function(){
                                    self.deleteTheme(node.data.id);
                                }
                            }
                        });
                        items.push({
                            text:'Export',
                            iconCls:'icon-document_out',
                            listeners:{
                                'click':function(){
                                    self.exportTheme(node.data.id);
                                }
                            }
                        });
                        var contextMenu = new Ext.menu.Menu({
                            items:items
                        });
                        contextMenu.showAt(e.xy);
                        return false;
                    }
                }
            },
            tbar:{
                items:[
                {
                    text:'Add Theme',
                    iconCls:'icon-add',
                    handler:function(btn){
                        var addThemeWindow = new Ext.Window({
                            layout:'fit',
                            width:375,
                            title:'New Theme',
                            height:325,
                            plain: true,
                            buttonAlign:'center',
                            items: new Ext.FormPanel({
                                labelWidth: 110,
                                frame:false,
                                bodyStyle:'padding:5px 5px 0',
                                fileUpload: true,
                                url:'./knitkit/theme/new',
                                defaults: {
                                    width: 225
                                },
                                items: [
                                {
                                    xtype:'combo',
                                    hiddenName:'site_id',
                                    name:'site_id',
                                    store:sitesJsonStore,
                                    forceSelection:true,
                                    editable:false,
                                    fieldLabel:'Website',
                                    emptyText:'Select Site...',
                                    typeAhead: false,
                                    mode: 'remote',
                                    displayField:'name',
                                    valueField:'id',
                                    triggerAction: 'all',
                                    allowBlank:false
                                },
                                {
                                    xtype:'textfield',
                                    fieldLabel:'Name',
                                    allowBlank:false,
                                    name:'name'
                                },
                                {
                                    xtype:'textfield',
                                    fieldLabel:'Theme ID',
                                    allowBlank:false,
                                    name:'theme_id'
                                },
                                {
                                    xtype:'textfield',
                                    fieldLabel:'Version',
                                    allowBlank:true,
                                    name:'version'
                                },
                                {
                                    xtype:'textfield',
                                    fieldLabel:'Author',
                                    allowBlank:true,
                                    name:'author'
                                },
                                {
                                    xtype:'textfield',
                                    fieldLabel:'HomePage',
                                    allowBlank:true,
                                    name:'homepage'
                                },
                                {
                                    xtype:'textarea',
                                    fieldLabel:'Summary',
                                    allowBlank:true,
                                    name:'summary'
                                }
                                ]
                            }),
                            buttons: [{
                                text:'Submit',
                                listeners:{
                                    'click':function(button){
                                        var window = button.findParentByType('window');
                                        var formPanel = window.query('form')[0];
                                        self.initialConfig['centerRegion'].setWindowStatus('Creating theme...');
                                        formPanel.getForm().submit({
                                            reset:true,
                                            success:function(form, action){
                                                self.initialConfig['centerRegion'].clearWindowStatus();
                                                var obj =  Ext.decode(action.response.responseText);
                                                if(obj.success){
                                                    self.getStore().load({node:self.getRootNode()});
                                                }
                                            },
                                            failure:function(form, action){
                                                self.initialConfig['centerRegion'].clearWindowStatus();
                                                Ext.Msg.alert("Error", "Error creating theme");
                                            }
                                        });
                                    }
                                }
                            },{
                                text: 'Close',
                                handler: function(){
                                    addThemeWindow.close();
                                }
                            }]
                        });
                        addThemeWindow.show();
                    }
                },
                {
                    text:'Upload Theme',
                    iconCls:'icon-upload',
                    handler:function(btn){
                        var uploadThemeWindow = new Ext.Window({
                            layout:'fit',
                            width:375,
                            title:'New Theme',
                            height:140,
                            plain: true,
                            buttonAlign:'center',
                            items: new Ext.FormPanel({
                                labelWidth: 110,
                                frame:false,
                                bodyStyle:'padding:5px 5px 0',
                                fileUpload: true,
                                url:'./knitkit/theme/new',
                                defaults: {
                                    width: 225
                                },
                                items: [
                                {
                                    xtype:'combo',
                                    hiddenName:'site_id',
                                    name:'site_id',
                                    store:sitesJsonStore,
                                    forceSelection:true,
                                    editable:false,
                                    fieldLabel:'Website',
                                    emptyText:'Select Site...',
                                    typeAhead: false,
                                    mode: 'remote',
                                    displayField:'name',
                                    valueField:'id',
                                    triggerAction: 'all',
                                    allowBlank:false
                                },
                                {
                                    xtype:'fileuploadfield',
                                    fieldLabel:'Upload Theme',
                                    buttonText:'Upload',
                                    buttonOnly:false,
                                    allowBlank:true,
                                    name:'theme_data'
                                }
                                ]
                            }),
                            buttons: [{
                                text:'Submit',
                                listeners:{
                                    'click':function(button){
                                        var window = button.findParentByType('window');
                                        var formPanel = window.query('form')[0];
                                        self.initialConfig['centerRegion'].setWindowStatus('Creating theme...');
                                        formPanel.getForm().submit({
                                            reset:true,
                                            success:function(form, action){
                                                self.initialConfig['centerRegion'].clearWindowStatus();
                                                var obj =  Ext.decode(action.response.responseText);
                                                if(obj.success){
                                                    self.getStore().load({node:self.getRootNode()});
                                                }
                                                uploadThemeWindow.close();
                                            },
                                            failure:function(form, action){
                                                self.initialConfig['centerRegion'].clearWindowStatus();
                                                Ext.Msg.alert("Error", "Error creating theme");
                                            }
                                        });
                                    }
                                }
                            },{
                                text: 'Close',
                                handler: function(){
                                    uploadThemeWindow.close();
                                }
                            }]
                        });
                        uploadThemeWindow.show();
                    }
                }
                ]
            }
        }, config);

        Compass.ErpApp.Desktop.Applications.ThemesTreePanel.superclass.constructor.call(this, config);
    }
});