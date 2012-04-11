Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.SectionArticlesGridPanel",{
  extend:"Ext.grid.Panel",
  alias:'widget.knitkit_sectionarticlesgridpanel',
  detachArticle : function(article_id){
    var self = this;
    this.initialConfig['centerRegion'].setWindowStatus('Detaching...');
    Ext.Ajax.request({
      url: '/knitkit/erp_app/desktop/section/detach_article',
      method: 'POST',
      params:{
        id:self.initialConfig['sectionId'],
        article_id:article_id
      },
      success: function(response) {
        var obj =  Ext.decode(response.responseText);
        if(obj.success){
          self.initialConfig['centerRegion'].clearWindowStatus();
          self.getStore().load();
        }
        else{
          Ext.Msg.alert('Error', 'Error detaching Article');
          self.initialConfig['centerRegion'].clearWindowStatus();
        }
      },
      failure: function(response) {
        self.initialConfig['centerRegion'].clearWindowStatus();
        Ext.Msg.alert('Error', 'Error detaching Article');
      }
    });
  },
    
  editArticle : function(record){
    var self = this;
    var addFormItems = self.addFormItems;
        
    var editArticleWindow = Ext.create("Ext.window.Window",{
      layout:'fit',
      width:375,
      title:'Edit Article',
      plain: true,
      buttonAlign:'center',
      items: {
        xtype: 'form',
        labelWidth: 110,
        frame:false,
        bodyStyle:'padding:5px 5px 0',
        width: 425,
        url:'/knitkit/erp_app/desktop/articles/update/' + self.sectionId,
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
        {
          xtype:'radiogroup',
          fieldLabel:'Display title?',
          name:'display_title',
          columns:2,
          items:[
          {
            boxLabel:'Yes',
            name:'display_title',
            inputValue: 'yes',
            checked:record.get('display_title')
          },
          {
            boxLabel:'No',
            name:'display_title',
            inputValue:'no',
            checked:!record.get('display_title')
          }]
        },
        {
          xtype:'textfield',
          fieldLabel:'Unique Name',
          allowBlank:true,
          name:'internal_identifier',
          value: record.get('internal_identifier')
        },
        addFormItems,
        {
          xtype: 'displayfield',
          fieldLabel: 'Created At',
          name: 'created_at',
          value: record.data.created_at
        },
        {
          xtype: 'displayfield',
          fieldLabel: 'Updated At',
          name: 'updated_at',
          value: record.data.updated_at
        }
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
            var formPanel = window.query('form')[0];
            self.initialConfig['centerRegion'].setWindowStatus('Updating article...');
            formPanel.getForm().submit({
              reset:false,
              success:function(form, action){
                self.initialConfig['centerRegion'].clearWindowStatus();
                var obj = Ext.decode(action.response.responseText);
                if(obj.success){
                  self.getStore().load();
                  if(formPanel.getForm().findField('tag_list')){
                    var tag_list = formPanel.getForm().findField('tag_list').getValue();
                    record.set('tag_list', tag_list);
                  }
                  if(formPanel.getForm().findField('content_area')){
                    var content_area = formPanel.getForm().findField('content_area').getValue();
                    record.set('content_area', content_area);
                  }
                  if(formPanel.getForm().findField('position')){
                    var position = formPanel.getForm().findField('position').getValue();
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
    Compass.ErpApp.Desktop.Applications.Knitkit.SectionArticlesGridPanel.superclass.initComponent.call(this, arguments);
    this.getStore().load();
  },
  
  constructor : function(config) {
    var self = this;
    var sectionId = config['sectionId'];

    // create the Data Store
    var store = Ext.create('Ext.data.Store', {
      pageSize: 10,
      proxy: {
        type: 'ajax',
        url:'/knitkit/erp_app/desktop/articles/get/' + sectionId,
        reader: {
          type: 'json',
          root: 'data'
        }
      },
      remoteSort: true,
      fields:[
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
      },
      {
        name:'internal_identifier'
      },
      {
        name:'display_title'
      },
      {
        name:'created_at'
      },
      {
        name:'updated_at'
      }
      ]
    });

    var overiddenColumns = [{
      header:'Title',
      sortable:true,
      dataIndex:'title',
      width:110
    }];

    if(!Compass.ErpApp.Utility.isBlank(config['columns'])){
      overiddenColumns = overiddenColumns.concat(config['columns']);
    }

       overiddenColumns = overiddenColumns.concat([
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
                    self.initialConfig['centerRegion'].editContent(rec.get('title'), rec.get('id'), rec.get('body_html'), grid.ownerCt.initialConfig.siteId, grid.ownerCt.initialConfig.contentType, grid.getStore());
                }
            }]
        }]);
        
        if (currentUser.hasApplicationCapability('knitkit', {
            capability_type_iid:'edit',
            resource:'Article'
        }))

        {
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
                    tooltip:'Edit Attributes',
                    handler :function(grid, rowIndex, colIndex){
                        var rec = grid.getStore().getAt(rowIndex);
                        self.editArticle(rec);
                    }
                }]
            }]);
        }

        if (currentUser.hasApplicationCapability('knitkit', {
            capability_type_iid:'delete',
            resource:'Article'
        }))

        {
            overiddenColumns = overiddenColumns.concat([
            {
                menuDisabled:true,
                resizable:false,
                xtype:'actioncolumn',
                header:'Detach',
                align:'center',
                width:40,
                items:[{
                    icon:'/images/icons/delete/delete_16x16.png',
                    tooltip:'Delete Article from Section',
                    handler :function(grid, rowIndex, colIndex){
                        var rec = grid.getStore().getAt(rowIndex);
                        var id = rec.get('id');
                        var messageBox = Ext.MessageBox.confirm(
                            'Confirm', 'Are you sure? NOTE: Article may be orphaned',
                            function(btn){
                                if (btn == 'yes'){
                                    self.detachArticle(id);
                                }
                            }
                            );
                    }
                }]
            }
            ]);
        }

    var addFormItems = [
    {
      xtype:'textfield',
      fieldLabel:'Title',
      allowBlank:false,
      name:'title'
    },
    {
      xtype:'radiogroup',
      fieldLabel:'Display title?',
      name:'display_title',
      columns:2,
      items:[
      {
        boxLabel:'Yes',
        name:'display_title',
        inputValue: 'yes',
        checked:true
      },

      {
        boxLabel:'No',
        name:'display_title',
        inputValue: 'no'
      }]
    },
    {
      xtype:'textfield',
      fieldLabel:'Unique Name',
      allowBlank:true,
      name:'internal_identifier'
    }
    ];

    if(!Compass.ErpApp.Utility.isBlank(config['addFormItems'])){
      addFormItems = addFormItems.concat(config['addFormItems']);
    }
    
        var tbarItems = [];

        if (currentUser.hasApplicationCapability('knitkit', {
            capability_type_iid:'create',
            resource:'Article'
        }))

        {
            tbarItems.push(
            {
                text: 'New Article',
                iconCls: 'icon-add',
                handler : function(){
                    var addArticleWindow = new Ext.Window({
                        layout:'fit',
                        width:375,
                        title:'New Article',
                        plain: true,
                        buttonAlign:'center',
                        items: new Ext.FormPanel({
                            labelWidth: 110,
                            frame:false,
                            bodyStyle:'padding:5px 5px 0',
                            width: 425,
                            url:'/knitkit/erp_app/desktop/articles/new/' + self.initialConfig['sectionId'],
                            defaults: {
                                width: 257
                            },
                            items: addFormItems
                        }),
                        buttons: [{
                            text:'Submit',
                            listeners:{
                                'click':function(button){
                                    var window = button.findParentByType('window');
                                    var formPanel = window.query('form')[0];
                                    self.initialConfig['centerRegion'].setWindowStatus('Creating article...');
                                    formPanel.getForm().submit({
                                        reset:true,
                                        success:function(form, action){
                                            self.initialConfig['centerRegion'].clearWindowStatus();
                                            var obj =  Ext.decode(action.response.responseText);
                                            if(obj.success){
                                                self.getStore().load();
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
            });
        }

        if (currentUser.hasApplicationCapability('knitkit', {
            capability_type_iid:'add_existing',
            resource:'Article'
        }))

        {
            tbarItems.push(
            {
                text: 'Attach Article',
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
                            labelWidth: 75,
                            frame:false,
                            bodyStyle:'padding:5px 5px 0',
                            width: 425,
                            url:'/knitkit/erp_app/desktop/articles/add_existing/' + self.initialConfig['sectionId'],
                            items:[
                            {
                                xtype:'combo',
                                hiddenName:'article_id',
                                name:'article_id',
                                labelWidth: 50,
                                width:200,
                                loadingText:'Retrieving Articles...',
                                store:Ext.create('Ext.data.Store',{
                                    proxy:{
                                        type:'ajax',
                                        reader:{
                                            type:'json',
                                            root:'articles'
                                        },
                                        extraParams:{
                                            section_id:self.initialConfig['sectionId']
                                        },
                                        url:'/knitkit/erp_app/desktop/section/available_articles'
                                    },
                                    fields:[
                                    {
                                        name:'id'
                                    },
                                    {
                                        name:'internal_identifier'

                                    }
                                    ]
                                }),
                                forceSelection:true,
                                editable:true,
                                fieldLabel:'Article',
                                autoSelect:true,
                                typeAhead: true,
                                mode: 'remote',
                                displayField:'internal_identifier',
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
                                    var formPanel = window.query('form')[0];
                                    self.initialConfig['centerRegion'].setWindowStatus('Adding article...');
                                    formPanel.getForm().submit({
                                        reset:true,
                                        success:function(form, action){
                                            self.initialConfig['centerRegion'].clearWindowStatus();
                                            var obj =  Ext.decode(action.response.responseText);
                                            if(obj.success){
                                                self.getStore().load();
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
            }
            );
        }
    
    config['columns'] = overiddenColumns;
    config = Ext.apply({
      store:store,
      tbar: tbarItems,
      bbar: new Ext.PagingToolbar({
        store: store,
        displayInfo: true,
        displayMsg: '{0} - {1} of {2}',
        emptyMsg: "Empty"
      })
    }, config);
  
    Compass.ErpApp.Desktop.Applications.Knitkit.SectionArticlesGridPanel.superclass.constructor.call(this, config);
  }
});

Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.PageArticlesGridPanel",{
  extend:"Compass.ErpApp.Desktop.Applications.Knitkit.SectionArticlesGridPanel",
  alias:'widget.knitkit_pagearticlesgridpanel',
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
        xtype:'numberfield',
        fieldLabel:'Position',
        name:'position',
        id: 'position'
      }
      ]
    }, config);

    Compass.ErpApp.Desktop.Applications.Knitkit.PageArticlesGridPanel.superclass.constructor.call(this, config);
  }
});

Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.BlogArticlesGridPanel",{
  extend:"Compass.ErpApp.Desktop.Applications.Knitkit.SectionArticlesGridPanel",
  alias:'widget.knitkit_blogarticlesgridpanel',
  initComponent: function() {
    Compass.ErpApp.Desktop.Applications.Knitkit.BlogArticlesGridPanel.superclass.initComponent.call(this, arguments);
  },

  constructor : function(config) {
    var self = this;
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
            self.initialConfig['centerRegion'].viewContentComments(rec.get('id'), rec.get('title') + ' - Comments');
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
          tooltip:'Edit Excerpt',
          handler :function(grid, rowIndex, colIndex){
            var rec = grid.getStore().getAt(rowIndex);
            self.initialConfig['centerRegion'].editExcerpt(rec.get('title') + ' - Excerpt', rec.get('id'), rec.get('excerpt_html'), self.initialConfig.siteId, grid.getStore());
          }
        }]
      }]
    }, config);

    Compass.ErpApp.Desktop.Applications.Knitkit.BlogArticlesGridPanel.superclass.constructor.call(this, config);
  }
});