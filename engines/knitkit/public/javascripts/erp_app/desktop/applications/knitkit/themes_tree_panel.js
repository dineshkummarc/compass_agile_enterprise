Compass.ErpApp.Desktop.Applications.ThemesTreePanel = Ext.extend(Compass.ErpApp.Shared.FileManagerTree, {
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
                var obj =  Ext.util.JSON.decode(response.responseText);
                if(obj.success){
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    self.getRootNode().reload();
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
  
    constructor : function(config) {
        var sitesJsonStore = new Ext.data.JsonStore({
            url:'./knitkit/site/index',
            root: 'sites',
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
            autoDestroy:true,
            allowDownload:true,
            addViewContentsToContextMenu:true,
            rootVisible:false,
            standardUploadUrl:'./knitkit/file_assets/upload_file',
            xhrUploadUrl:'./knitkit/file_assets/upload_file',
            loader: new Ext.tree.TreeLoader({
                dataUrl:'./knitkit/theme/index'
            }),
            containerScroll: true,
            listeners:{
                'contentLoaded':function(fileManager, node, content){
                    self.initialConfig['centerRegion'].editTemplateFile(node, content, []);
                },
                'handleContextMenu':function(fileManager, node, e){
                    if(node.attributes['isTheme']){
                        var items = [];
                        if(node.attributes['isActive']){
                            items.push({
                                text:'Deactivate',
                                iconCls:'icon-delete',
                                listeners:{
                                    'click':function(){
                                        self.updateThemeActiveStatus(node.id, node.attributes['siteId'], false);
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
                                        self.updateThemeActiveStatus(node.id, node.attributes['siteId'], true);
                                    }
                                }
                            });
                        }
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
                            height:300,
                            plain: true,
                            buttonAlign:'center',
                            items: new Ext.FormPanel({
                                labelWidth: 110,
                                frame:false,
                                bodyStyle:'padding:5px 5px 0',
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
                                    allowBlank:false,
                                    name:'version'
                                },
                                {
                                    xtype:'textfield',
                                    fieldLabel:'Author',
                                    allowBlank:false,
                                    name:'author'
                                },
                                {
                                    xtype:'textfield',
                                    fieldLabel:'HomePage',
                                    allowBlank:false,
                                    name:'homepage'
                                },
                                {
                                    xtype:'textarea',
                                    fieldLabel:'Summary',
                                    allowBlank:false,
                                    name:'summary'
                                }
                                ]
                            }),
                            buttons: [{
                                text:'Submit',
                                listeners:{
                                    'click':function(button){
                                        var window = button.findParentByType('window');
                                        var formPanel = window.findByType('form')[0];
                                        self.initialConfig['centerRegion'].setWindowStatus('Creating theme...');
                                        formPanel.getForm().submit({
                                            reset:true,
                                            success:function(form, action){
                                                self.initialConfig['centerRegion'].clearWindowStatus();
                                                var obj =  Ext.util.JSON.decode(action.response.responseText);
                                                if(obj.success){
                                                    self.getRootNode().reload();
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
                }
                ]
            }
        }, config);

        Compass.ErpApp.Desktop.Applications.ThemesTreePanel.superclass.constructor.call(this, config);
    }
});

//uncomment and give an xtype if you want this class to use an xtype
Ext.reg('knitkit_themestreepanel', Compass.ErpApp.Desktop.Applications.ThemesTreePanel);
