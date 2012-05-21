//
//module
//

Ext.define("Compass.ErpApp.Desktop.Applications.ProductManager",{
  extend:"Ext.ux.desktop.Module",
  id:'product_manager-win',
  init : function(){
    this.launcher = {
      text: 'Products',
      iconCls:'icon-product',
      handler : this.createWindow,
      scope: this
    }
  },
  createWindow : function(){
    var desktop = this.app.getDesktop();
    var win = desktop.getWindow('product_manager');
    if(!win){
      win = desktop.createWindow({
        id: 'product_manager',
        title:'Products',
        width:1000,
        height:550,
        iconCls: 'icon-product',
        shim:false,
        animCollapse:false,
        constrainHeader:true,
        layout: 'fit',
        items:[{
          xtype:'productmanagement_productspanel'
        }]
      });
    }
    win.show();
  }
});

Compass.ErpApp.Desktop.Applications.ProductManager.widgets = [];
Compass.ErpApp.Desktop.Applications.ProductManager.selectedProductTypeId = null;

//
//form to manage description and title
//

Ext.define("Compass.ErpApp.Desktop.Applications.ProductManager.ProductDescriptionForm",{
  extend:"Ext.form.Panel",
  alias:'widget.productmanager_productdescriptionform',
  initComponent: function() {
    this.callParent(arguments);

    this.addEvents(
      /**
         * @event saved
         * Fired after form is saved.
         * @param {Compass.ErpApp.Desktop.Applications.ProductManager.ProductDescriptionForm} form this object
         * @param {integer} Newly create id
         */
      'saved'
      );
  },

  constructor : function(config) {
    var self = this;
    config = Ext.apply({
      buttonAlign:'center',
      bodyStyle:'padding:5px 5px 0',
      items: [
      {
        fieldLabel:'Title',
        xtype:'textfield',
        allowBlank:false,
        width:500,
        name:'title'

      },
      {
        xtype : 'label',
        html : 'Describe your product:',
        cls : "x-form-item x-form-item-label card-label"
      },
      {
        xtype: 'ckeditor',
        allowBlank:false,
        autoHeight:true,
        ckEditorConfig:{
          height:'290px',
          width:750,
          extraPlugins:'jwplayer',
          toolbar:[
          ['Source','-','CompassSave','Preview','Print','-','Templates',
          'Cut','Copy','Paste','PasteText','PasteFromWord','Undo','Redo'],
          ['Find','Replace','SpellChecker', 'Scayt','-','SelectAll'],
          ['TextColor','BGColor'],
          ['Bold','Italic','Underline','Strike','-','Subscript','Superscript','-','RemoveFormat'],
          ['NumberedList','BulletedList','-','Outdent','Indent','Blockquote','CreateDiv'],
          '/',
          ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','-','BidiLtr','BidiRtl'],
          ['BidiLtr', 'BidiRtl' ],
          ['Link','Unlink','Anchor'],
          ['jwplayer','Flash','Table','HorizontalRule',,'SpecialChar','PageBreak',],
          [ 'Styles','Format','Font','FontSize' ],
          ['Maximize', 'ShowBlocks','-','About']
          ]
        }
      },
      {
        xtype:'hidden',
        name:'description'
      }
      ],
      buttons:[
      {
        text:'Save',
        handler:function(btn){
          var formPanel = btn.findParentByType('form');
          var basicForm = formPanel.getForm();

          //ckeditor does not post.  Get the value and set to hidden field
          var ckeditor = formPanel.query('ckeditor').first();
          basicForm.findField('description').setValue(ckeditor.getValue());

          basicForm.submit({
            success:function(form, action){
              var obj = Ext.decode(action.response.responseText);
              if(obj.success){
                self.fireEvent('saved', this, obj.id);
              }
              else{
                Ext.Msg.alert("Error", 'Error creating product');
              }
            },
            failure:function(form, action){
              Ext.Msg.alert("Error", 'Error creating product');
            }
          });
        }
      }
      ]
    }, config);

    this.callParent([config]);
  }
});

//
//Panel for product images
//

Ext.define("Compass.ErpApp.Desktop.Applications.ProductManager.ProductImagesPanel",{
  extend:"Ext.panel.Panel",
  alias:'widget.productmanager_productimagespanel',
  deleteImage : function(id){
    var self = this;
    Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this image?', function(btn){
      if(btn == 'no'){
        return false;
      }
      else
      {
        Ext.Ajax.request({
          url: '/erp_products/erp_app/desktop/product_manager/delete_image/'+id,
          success: function(response) {
            var obj =  Ext.decode(response.responseText);
            if(obj.success){
              self.imageAssetsDataView.getStore().load();
            }
            else{
              Ext.Msg.alert('Error', 'Error deleting image.');
            }
          },
          failure: function(response) {
            Ext.Msg.alert('Error', 'Error deleting image.');
          }
        });
      }
    });
  },

  constructor : function(config) {
    var self = this;
    var productTypeId = config.productTypeId;
    var uploadUrl = '/erp_products/erp_app/desktop/product_manager/new_image'
        
    this.imageAssetsDataView = Ext.create("Ext.view.View",{
      autoDestroy:true,
      itemSelector: 'div.thumb-wrap',
      style:'overflow:auto',
      store: Ext.create("Ext.data.Store",{
        autoLoad: true,
        proxy:{
          type:'ajax',
          url: '/erp_products/erp_app/desktop/product_manager/images/'+productTypeId,
          reader:{
            root: 'images',
            type:'json'
          }
        },
        fields:['name', 'url', 'shortName', 'id']
      }),
      tpl: new Ext.XTemplate(
        '<tpl for=".">',
        '<div class="thumb-wrap" id="{name}">',
        '<div class="thumb"><img src="{url}" class="thumb-img"></div>',
        '<span>{shortName}</span></div>',
        '</tpl>'
        ),
      listeners:{
        'itemcontextmenu':function(view, record, htmlitem, index, e, options){
          e.stopEvent();
          var contextMenu = Ext.create("Ext.menu.Menu",{
            items:[
            {
              text:'Delete',
              iconCls:'icon-delete',
              handler:function(btn){
                self.deleteImage(self.imageAssetsDataView.getStore().getAt(index).get('id'));
              }
            }
            ]
          });
          contextMenu.showAt(e.xy);
        }
      }
    });

    config = Ext.apply({
      id:'product-image-assets',
      title:'Images',
      autoDestroy:true,
      margins: '5 5 5 0',
      autoHeight:true,
      layout:'fit',
      items:[this.imageAssetsDataView],
      tbar:{
        items:[
        {
          text:'Add Image',
          iconCls:'icon-upload',
          handler:function(btn){
            var uploadWindow = Ext.create("Compass.ErpApp.Shared.UploadWindow",{
              standardUploadUrl:uploadUrl,
              flashUploadUrl:uploadUrl,
              xhrUploadUrl:uploadUrl,
              extraPostData:{
                product_type_id:productTypeId
              },
              listeners:{
                'fileuploaded':function(){
                  var dataView = btn.findParentByType('panel').query('dataview')[0];
                  dataView.getStore().load();
                  Ext.getCmp('productListPanel').loadProducts();
                }
              }
            });
            uploadWindow.show();
          }
        }
        ]
      }
    }, config);

     this.callParent([config]);
  }
});

//
//Add product window
//

Ext.define("Compass.ErpApp.Desktop.Applications.ProductManager.AddProductWindow",{
  extend:"Ext.window.Window",
  alias:'widget.productmanager_addproductwindow',

  constructor : function(config) {
    var self = this;
    config = Ext.apply({
      title:'Add New Product',
      width:800,
      layout:'fit',
      height:600,
      autoScroll:true,
      buttonAlign:'center',
      items:{
        xtype:'productmanager_productdescriptionform',
        url:'/erp_products/erp_app/desktop/product_manager/new',
        listeners:{
          saved:function(form, newId){
            Ext.getCmp('productListPanel').loadProducts();
            var win = new Compass.ErpApp.Desktop.Applications.ProductManager.UpdateProductWindow({
              productTypeId:newId
            });
            win.show();
            self.close();
          }
        }
      }
    }, config);

    this.callParent([config]);
  }
});

//
//Update product window
//

Ext.define("Compass.ErpApp.Desktop.Applications.ProductManager.UpdateProductWindow",{
  extend:"Ext.window.Window",
  alias:'widget.productmanager_updateproductwindow',
  constructor : function(config) {
    var self = this;
    var activeTab = config['activeTab'] | 0
    Compass.ErpApp.Desktop.Applications.ProductManager.selectedProductTypeId = config.productTypeId;

    var tabLayout = {
      xtype:'tabpanel',
      items:[
      {
        title:'Description',
        xtype:'productmanager_productdescriptionform',
        url:'/erp_products/erp_app/desktop/product_manager/update/'+config.productTypeId,
        productTypeId:config.productTypeId,
        listeners:{
          'saved':function(form){
            Ext.getCmp('productListPanel').loadProducts();
          },
          'activate':function(panel){
            if(!Compass.ErpApp.Utility.isBlank(panel.initialConfig['productTypeId'])){
              var self = this;
              Ext.Ajax.request({
                url: '/erp_products/erp_app/desktop/product_manager/show/'+panel.initialConfig['productTypeId'],
                success: function(response) {
                  var obj =  Ext.decode(response.responseText);
                  self.getForm().setValues(obj);
                  self.query('ckeditor')[0].setValue(obj.description);
                },
                failure: function(response) {
                  Ext.Msg.alert('Error', 'Error loading product details.');
                }
              });
            }
          }

        }
      },
      {
        xtype:'productmanager_productimagespanel',
        productTypeId:config.productTypeId
      }
      ]
    }

    config = Ext.apply({
      title:'Update Product',
      width:860,
      layout:'fit',
      height:620,
      autoScroll:true,
      items:[tabLayout],
      listeners:{
        show:function(comp){
          var tabPanel = comp.down('tabpanel');
          
          Ext.each(Compass.ErpApp.Desktop.Applications.ProductManager.widgets,function(widget){
              tabPanel.add(widget);
          });

          tabPanel.setActiveTab(activeTab);
        }
      }
    }, config);

    this.callParent([config]);
  }
});