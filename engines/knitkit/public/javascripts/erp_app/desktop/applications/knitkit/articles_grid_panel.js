Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.ArticlesGridPanel",{
  extend:"Ext.grid.Panel",
  alias:'widget.knitkit_articlesgridpanel',
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
        var obj = Ext.decode(response.responseText);
        if(obj.success){
          self.initialConfig['centerRegion'].clearWindowStatus();
          self.getStore().load();
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
        url:'./knitkit/articles/update/',
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
        {
          xtype:'textfield',
          fieldLabel:'Tags',
          allowBlank:true,
          name:'tags',
          id: 'tag_list',
          value: record.get('tag_list')
        },
        {
          xtype:'hidden',
          allowBlank:false,
          name:'id',
          id: 'record_id',
          value: record.get('id')
        },
        ]
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

    // create the Data Store
    var store = Ext.create('Ext.data.Store', {
      proxy: {
        type: 'ajax',
        url:'./knitkit/articles/all/',
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
        name:'body_html'
      },
      {
        name:'sections'
      },
      {
        name:'internal_identifier'
      },
      {
        name:'display_title'
      },
      {
        name:'created_by'
      },
      {
        name:'last_update_by'
      }
      ]
    });

    config = Ext.apply({
      title:'Articles',
      columns:[
      {
        header:'Title',
        sortable:true,
        dataIndex:'title',
        width:110,
        editable:false
      },
      {
        header:'Unique Name',
        sortable:true,
        dataIndex:'internal_identifier',
        width:110,
        editable:false
      },
      {
        header:'Created By',
        sortable:false,
        dataIndex:'created_by',
        width:110,
        menuDisabled:true,
        editable:false
      },
      {
        header:'Last Update By',
        sortable:false,
        dataIndex:'last_update_by',
        width:110,
        menuDisabled:true,
        editable:false
      },
      {
        menuDisabled:true,
        resizable:false,
        xtype:'actioncolumn',
        header:'Tags',
        align:'center',
        width:40,
        items:[{
          getClass: function(v, meta, rec) {  // Or return a class from a function
            this.items[0].tooltip = rec.get('tag_list');
            return 'info-col';
          },
          handler :function(grid, rowIndex, colIndex){
            return true;
          }
        }]
      },
      {
        menuDisabled:true,
        resizable:false,
        xtype:'actioncolumn',
        header:'Sections',
        align:'center',
        width:50,
        items:[{
          getClass: function(v, meta, rec) {  // Or return a class from a function
            this.items[0].tooltip = rec.get('sections');
            return 'info-col';
          },
          handler :function(grid, rowIndex, colIndex){
            return true;
          }
        }]
      },
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
      },
      {
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
            self.initialConfig['centerRegion'].editExcerpt(rec.get('title') + ' - Excerpt', rec.get('id'), rec.get('excerpt_html'), self.initialConfig.siteId);
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
            self.initialConfig['centerRegion'].editContent(rec.get('title'), rec.get('id'), rec.get('body_html'), null, 'blog');
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
            var messageBox = Ext.MessageBox.confirm(
              'Confirm', 'Are you sure?',
              function(btn){
                if (btn == 'yes'){
                  self.deleteArticle(id);
                }
              }
              );
          }
        }]
      }
      ],
      store:store,
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
              url:'./knitkit/articles/new/',
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
              },
              {
                xtype:'textfield',
                fieldLabel:'Tags',
                allowBlank:true,
                name:'tags',
                id: 'tag_list'
              }
              ]
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
      },
      '|',
      {
        xtype:'textfield',
        hideLabel:true,
        id:'global_article_search_field'
      },
      {
        text: 'Search',
        iconCls: 'icon-search',
        handler: function(button) {
          var iid = Ext.getCmp('global_article_search_field').getValue();
          store.setProxy({
            type: 'ajax',
            url: './knitkit/articles/all/',
            reader: {
              type: 'json',
              root: 'data',
              idProperty: 'id',
              totalProperty:'totalCount'
            },
            extraParams:{
              iid:iid
            }
          });
          store.loadPage(1);
        }
      }],
      bbar: new Ext.PagingToolbar({
        pageSize: 40,
        store: store,
        displayInfo: true,
        displayMsg: '{0} - {1} of {2}',
        emptyMsg: "Empty"
      }),
      autoScroll:true
    }, config);

    Compass.ErpApp.Desktop.Applications.Knitkit.ArticlesGridPanel.superclass.constructor.call(this, config);
  }
});


