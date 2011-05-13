Compass.ErpApp.Desktop.Applications.Knitkit.ArticlesGridPanel = Ext.extend(Ext.grid.EditorGridPanel, {
    deleteArticle : function(id){
        var self = this;
        this.initialConfig['centerRegion'].setWindowStatus('Deleting...');
        var conn = new Ext.data.Connection();
        conn.request({
            url: './knitkit/articles/delete',
            method: 'POST',
            params:{
                id:id
            },
            success: function(response) {
                var obj =  Ext.util.JSON.decode(response.responseText);
                if(obj.success){
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    self.getStore().reload();
                }
                else{
                    Ext.Msg.alert('Error', 'Error deleting Article');
                    self.initialConfig['centerRegion'].clearWindowStatus();
                }
            },
            failure: function(response) {
                self.initialConfig['centerRegion'].clearWindowStatus();
                Ext.Msg.alert('Error', 'Error deleting Article');
            }
        });
    },
    
    editArticle : function(record){
        var self = this;
        var addFormItems = self.addFormItems;
        
        var editArticleWindow = new Ext.Window({
            layout:'fit',
            width:375,
            title:'Edit Article',
            height:160,
            plain: true,
            buttonAlign:'center',
            items: {
                xtype: 'form',
                labelWidth: 110,
                frame:false,
                bodyStyle:'padding:5px 5px 0',
                width: 425,
                url:'./knitkit/articles/update/' + self.sectionId,
                defaults: {
                    width: 225
                },
                items: [
                {
                    xtype:'textfield',
                    fieldLabel:'Title',
                    allowBlank:false,
                    name:'title',
                    value: record.get('title')
                },
                addFormItems
                ]
            },
            listeners:{
              'show':function(){
                if (Ext.getCmp('record_id')){                  
                  Ext.getCmp('record_id').setValue(record.get('id'));
                }
                if (Ext.getCmp('tag_list')){                  
                  Ext.getCmp('tag_list').setValue(record.get('tag_list'));
                }
                if (Ext.getCmp('content_area')){                  
                  Ext.getCmp('content_area').setValue(record.get('content_area'));
                }
                if (Ext.getCmp('position')){                  
                  Ext.getCmp('position').setValue(record.get('position'));
                }
              }              
            },
            buttons: [{
                text:'Submit',
                listeners:{
                    'click':function(button){
                        var window = button.findParentByType('window');
                        var formPanel = window.findByType('form')[0];
                        self.initialConfig['centerRegion'].setWindowStatus('Updating article...');                        
                        formPanel.getForm().submit({
                            reset:false,
                            success:function(form, action){
                                self.initialConfig['centerRegion'].clearWindowStatus();
                                var obj =  Ext.util.JSON.decode(action.response.responseText);
                                if(obj.success){
                                    self.getStore().reload();
                                    if(formPanel.getForm().findField('tag_list')){
                                      tag_list = formPanel.getForm().findField('tag_list').getValue();                       
                                      record.set('tag_list', tag_list);
                                    }
                                    if(formPanel.getForm().findField('content_area')){
                                      content_area = formPanel.getForm().findField('content_area').getValue();
                                      record.set('content_area', content_area);
                                    }
                                    if(formPanel.getForm().findField('position')){
                                      position = formPanel.getForm().findField('position').getValue();
                                      record.set('position', position);
                                    }                                    
                                    editArticleWindow.close();                                    
                                }
                                else{
                                    Ext.Msg.alert("Error", obj.msg);
                                }
                            },
                            failure:function(form, action){
                                self.initialConfig['centerRegion'].clearWindowStatus();
                                Ext.Msg.alert("Error", "Error updating article");
                            }
                        });
                    }
                }
            },{
                text: 'Close',
                handler: function(){
                    editArticleWindow.close();
                }
            }]
        });
        editArticleWindow.show();
    },

    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.Knitkit.ArticlesGridPanel.superclass.initComponent.call(this, arguments);
        this.getStore().load();
    },
  
    constructor : function(config) {
        var self = this;
        var sectionId = config['sectionId'];
        var fm = Ext.form;

        // create the Data Store
        var store = new Ext.data.JsonStore({
            root: 'data',
            totalProperty: 'totalCount',
            idProperty: 'id',
            remoteSort: true,
            fields: [
            {
                name:'id'
            },
            {
                name:'title'
            },
            {
                name:'tag_list'
            },
            {
                name:'excerpt_html'
            },
            {
                name:'position'
            },
            {
                name:'content_area'
            },
            {
                name:'body_html'
            }
            ],
            url:'./knitkit/articles/get/' + sectionId
        });

        var overiddenColumns = [{
            header:'Title',
            sortable:true,
            dataIndex:'title',
            width:110,
            editable:false,
            editor: new fm.TextField({
                allowBlank: false
            })
        }];

        if(!Compass.ErpApp.Utility.isBlank(config['columns'])){
            overiddenColumns = overiddenColumns.concat(config['columns']);
        }

        overiddenColumns = overiddenColumns.concat([
          {
              menuDisabled:true,
              resizable:false,
              xtype:'actioncolumn',
              header:'Edit',
              align:'center',
              width:40,
              items:[{
                  icon:'/images/icons/edit/edit_16x16.png',
                  tooltip:'Edit',
                  handler :function(grid, rowIndex, colIndex){
                      var rec = grid.getStore().getAt(rowIndex);
                      self.editArticle(rec);
                  }
              }]
          },
        {
            menuDisabled:true,
            resizable:false,
            xtype:'actioncolumn',
            header:'HTML',
            align:'center',
            width:40,
            items:[{
                icon:'/images/icons/edit/edit_16x16.png',
                tooltip:'Edit',
                handler :function(grid, rowIndex, colIndex){
                    var rec = grid.getStore().getAt(rowIndex);
                    self.initialConfig['centerRegion'].editContent(rec.get('title'), rec.get('id'), rec.get('body_html'), grid.initialConfig.siteId, grid.initialConfig.contentType);
                }
            }]
        },
        {
            menuDisabled:true,
            resizable:false,
            xtype:'actioncolumn',
            header:'Delete',
            align:'center',
            width:40,
            items:[{
                icon:'/images/icons/delete/delete_16x16.png',
                tooltip:'Delete',
                handler :function(grid, rowIndex, colIndex){
                    var rec = grid.getStore().getAt(rowIndex);
                    var id = rec.get('id');
                    self.deleteArticle(id);
                }
            }]
        }
        ]);

        var addFormItems = [
        {
            xtype:'textfield',
            fieldLabel:'Title',
            allowBlank:false,
            name:'title'
        }        
        ];

        if(!Compass.ErpApp.Utility.isBlank(config['addFormItems'])){
            addFormItems = addFormItems.concat(config['addFormItems']);
        }
        
        config['columns'] = overiddenColumns;
        config = Ext.apply({
            store:store,
            clicksToEdit: 1,
            tbar: [{
                text: 'Add New Article',
                iconCls: 'icon-add',
                handler : function(){
                    var addArticleWindow = new Ext.Window({
                        layout:'fit',
                        width:375,
                        title:'New Article',
                        height:config['addFormHeight'],
                        plain: true,
                        buttonAlign:'center',
                        items: new Ext.FormPanel({
                            labelWidth: 110,
                            frame:false,
                            bodyStyle:'padding:5px 5px 0',
                            width: 425,
                            url:'./knitkit/articles/new/' + self.initialConfig['sectionId'],
                            defaults: {
                                width: 225
                            },
                            items: addFormItems
                        }),
                        buttons: [{
                            text:'Submit',
                            listeners:{
                                'click':function(button){
                                    var window = button.findParentByType('window');
                                    var formPanel = window.findByType('form')[0];
                                    self.initialConfig['centerRegion'].setWindowStatus('Creating article...');
                                    formPanel.getForm().submit({
                                        reset:true,
                                        success:function(form, action){
                                            self.initialConfig['centerRegion'].clearWindowStatus();
                                            var obj =  Ext.util.JSON.decode(action.response.responseText);
                                            if(obj.success){
                                                self.getStore().reload();
                                            }
                                            else{
                                                Ext.Msg.alert("Error", obj.msg);
                                            }
                                            addArticleWindow.close();
                                            
                                        },
                                        failure:function(form, action){
                                            self.initialConfig['centerRegion'].clearWindowStatus();
                                            Ext.Msg.alert("Error", "Error creating article");
                                        }
                                    });
                                }
                            }
                        },{
                            text: 'Close',
                            handler: function(){
                                addArticleWindow.close();
                            }
                        }]
                    });
                    addArticleWindow.show();
                }
            },
            {
                text: 'Add Existing Article',
                iconCls: 'icon-copy',
                handler : function(){
                    var addExistingArticleWindow = new Ext.Window({
                        layout:'fit',
                        width:375,
                        title:'Add Existing Article',
                        height:100,
                        plain: true,
                        buttonAlign:'center',
                        items: new Ext.FormPanel({
                            labelWidth: 110,
                            frame:false,
                            bodyStyle:'padding:5px 5px 0',
                            width: 425,
                            url:'./knitkit/articles/add_existing/' + self.initialConfig['sectionId'],
                            items:[
                            {
                                xtype:'combo',
                                hiddenName:'article_id',
                                name:'article_id',
                                loadingText:'Retrieving Articles...',
                                store:{
                                    xtype:'jsonstore',
                                    baseParams:{
                                        section_id:self.initialConfig['sectionId']
                                    },
                                    url:'./knitkit/section/available_articles',
                                    fields:[
                                    {
                                        name:'id'
                                    },
                                    {
                                        name:'title'

                                    }
                                    ]
                                },
                                forceSelection:true,
                                editable:true,
                                fieldLabel:'Article',
                                autoSelect:true,
                                typeAhead: true,
                                mode: 'remote',
                                displayField:'title',
                                valueField:'id',
                                triggerAction: 'all',
                                allowBlank:false
                            }
                            ]
                        }),
                        buttons: [{
                            text:'Submit',
                            listeners:{
                                'click':function(button){
                                    var window = button.findParentByType('window');
                                    var formPanel = window.findByType('form')[0];
                                    self.initialConfig['centerRegion'].setWindowStatus('Adding article...');
                                    formPanel.getForm().submit({
                                        reset:true,
                                        success:function(form, action){
                                            self.initialConfig['centerRegion'].clearWindowStatus();
                                            var obj =  Ext.util.JSON.decode(action.response.responseText);
                                            if(obj.success){
                                                self.getStore().reload();
                                            }else{
                                                Ext.Msg.alert("Error", "Error Adding article");
                                            }
                                        },
                                        failure:function(form, action){
                                            self.initialConfig['centerRegion'].clearWindowStatus();
                                            Ext.Msg.alert("Error", "Error Adding article");
                                        }
                                    });
                                }
                            }
                        },{
                            text: 'Close',
                            handler: function(){
                                addExistingArticleWindow.close();
                            }
                        }]
                    });
                    addExistingArticleWindow.show();
                }
            }],
            bbar: new Ext.PagingToolbar({
                pageSize: 10,
                store: store,
                displayInfo: true,
                displayMsg: '{0} - {1} of {2}',
                emptyMsg: "Empty"
            })
        }, config);
  
        Compass.ErpApp.Desktop.Applications.Knitkit.ArticlesGridPanel.superclass.constructor.call(this, config);
    }
});

Compass.ErpApp.Desktop.Applications.Knitkit.PageArticlesGridPanel = Ext.extend(Compass.ErpApp.Desktop.Applications.Knitkit.ArticlesGridPanel, {
    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.Knitkit.PageArticlesGridPanel.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        config['contentType'] = 'article';
        var fm = Ext.form;
        config = Ext.apply({
            columns:[{
                sortable:true,
                resizable:false,
                header:'Content Area',
                dataIndex:'content_area',
                width:80,
                editable:false,
                editor: new fm.TextField({
                    allowBlank: false
                })
            },
            {
                menuDisabled:true,
                resizable:false,
                header:'Pos',
                sortable:true,
                dataIndex:'position',
                width:30,
                editable:false,
                editor: new fm.TextField({
                    allowBlank: true
                })
            }],
            addFormHeight:160,
            addFormItems:[
            {
                 xtype:'hidden',
                 allowBlank:false,
                 name:'id',
                 id: 'record_id'
            },
            {
                xtype:'textfield',
                fieldLabel:'Content Area',
                name:'content_area',
                id: 'content_area'
            },
            {
                xtype:'textfield',
                fieldLabel:'Position',
                name:'position',
                id: 'position'
            }
            ]
        }, config);

        Compass.ErpApp.Desktop.Applications.Knitkit.PageArticlesGridPanel.superclass.constructor.call(this, config);
    }
});

Ext.reg('knitkit_pagearticlesgridpanel', Compass.ErpApp.Desktop.Applications.Knitkit.PageArticlesGridPanel);

Compass.ErpApp.Desktop.Applications.Knitkit.BlogArticlesGridPanel = Ext.extend(Compass.ErpApp.Desktop.Applications.Knitkit.ArticlesGridPanel, {
    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.Knitkit.BlogArticlesGridPanel.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        config['contentType'] = 'blog';
        config = Ext.apply({
            addFormHeight:200,
            addFormItems:[
             {
                  xtype:'hidden',
                  allowBlank:false,
                  name:'id',
                  id: 'record_id'
              },
              {
                  xtype:'textfield',
                  fieldLabel:'Tags',
                  allowBlank:true,
                  name:'tags',
                  id: 'tag_list'
              }            
            ],
            columns:[{
                menuDisabled:true,
                resizable:false,
                xtype:'actioncolumn',
                header:'Comments',
                align:'center',
                width:60,
                items:[{
                    icon:'/images/icons/document_text/document_text_16x16.png',
                    tooltip:'Comments',
                    handler :function(grid, rowIndex, colIndex){
                        var rec = grid.getStore().getAt(rowIndex);
                        grid.initialConfig['centerRegion'].viewContentComments(rec.get('id'), rec.get('title') + ' - Comments');
                    }
                }]
            },{
                menuDisabled:true,
                resizable:false,
                xtype:'actioncolumn',
                header:'Excerpt',
                align:'center',
                width:50,
                items:[{
                    icon:'/images/icons/edit/edit_16x16.png',
                    tooltip:'Edit',
                    handler :function(grid, rowIndex, colIndex){
                        var rec = grid.getStore().getAt(rowIndex);
                        grid.initialConfig['centerRegion'].editExcerpt(rec.get('title') + ' - Excerpt', rec.get('id'), rec.get('excerpt_html'), grid.initialConfig.siteId);
                    }
                }]
            }]
        }, config);

        Compass.ErpApp.Desktop.Applications.Knitkit.BlogArticlesGridPanel.superclass.constructor.call(this, config);
    }
});


Ext.reg('knitkit_blogarticlesgridpanel', Compass.ErpApp.Desktop.Applications.Knitkit.BlogArticlesGridPanel);

