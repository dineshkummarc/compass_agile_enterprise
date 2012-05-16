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

//
//form to manage description and title
//

Ext.define("Compass.ErpApp.Desktop.Applications.ProductManager.ProductDescriptionForm",{
  extend:"Ext.form.Panel",
  alias:'widget.productmanager_productdescriptionform',
  initComponent: function() {
    Compass.ErpApp.Desktop.Applications.ProductManager.ProductDescriptionForm.superclass.initComponent.call(this, arguments);

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

    Compass.ErpApp.Desktop.Applications.ProductManager.ProductDescriptionForm.superclass.constructor.call(this, config);
  }
});

//
//form to manage pricing
//

Ext.define("Compass.ErpApp.Desktop.Applications.ProductManager.ProductPricingPanel",{
  extend:"Ext.panel.Panel",
  alias:'widget.productmanager_productpricingpanel',
  updatePrice : function(rec){
    this.addEditPriceBtn.setText('Update Price');
    this.cancelBtn.show();
    this.addPriceFormPanel.getForm().setValues(rec.data);
  },

  deletePrice : function(rec){
    var self = this;
    Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this price?', function(btn){
      if(btn == 'no'){
        return false;
      }
      else
      {
        Ext.Ajax.request({
          url: '/erp_products/erp_app/desktop/product_manager/delete_price/'+rec.get('pricing_plan_id'),
          success: function(response) {
            var obj =  Ext.decode(response.responseText);
            if(obj.success){
              Ext.getCmp('productListPanel').loadProducts();
              self.pricesGridPanel.getStore().load();
            }
            else{
              Ext.Msg.alert('Error', 'Error deleting price.');
            }
          },
          failure: function(response) {
            Ext.Msg.alert('Error', 'Error deleting price.');
          }
        });
      }
    });
  },

  initComponent: function() {
    Compass.ErpApp.Desktop.Applications.ProductManager.ProductPricingPanel.superclass.initComponent.call(this, arguments);
  },

  constructor : function(config) {
    var self = this;

    this.pricesGridPanel = Ext.create("Ext.grid.Panel",{
      layout:'fit',
      region:'center',
      split:true,
      columns: [
      {
        header:'Description',
        width:310,
        sortable: false,
        dataIndex: 'description'
      },
      {
        header: 'Price',
        width: 75,
        sortable: true,
        dataIndex: 'price',
        renderer:function(v){
          return v.toFixed(2);
        }
      },
      {
        header: 'Currency',
        width: 75,
        sortable: true,
        dataIndex: 'currency_display'
      },
      {
        header: 'From Date',
        width: 90,
        sortable: true,
        dataIndex: 'from_date',
        renderer: Ext.util.Format.dateRenderer('m/d/Y')
      },
      {
        header: 'Thru Date',
        width: 90,
        sortable: true,
        dataIndex: 'thru_date',
        renderer: Ext.util.Format.dateRenderer('m/d/Y')
      },
      {
        menuDisabled:true,
        resizable:false,
        xtype:'actioncolumn',
        header:'Update',
        align:'center',
        width:60,
        items:[{
          icon:'/images/icons/edit/edit_16x16.png',
          tooltip:'Update',
          handler :function(grid, rowIndex, colIndex){
            var rec = grid.getStore().getAt(rowIndex);
            self.updatePrice(rec);
          }
        }]
      },
      {
        menuDisabled:true,
        resizable:false,
        xtype:'actioncolumn',
        header:'Delete',
        align:'center',
        width:60,
        items:[{
          icon:'/images/icons/delete/delete_16x16.png',
          tooltip:'Delete',
          handler :function(grid, rowIndex, colIndex){
            var rec = grid.getStore().getAt(rowIndex);
            self.deletePrice(rec);
          }
        }]
      },
      {
        menuDisabled:true,
        resizable:false,
        xtype:'actioncolumn',
        header:'Comment',
        align:'center',
        width:60,
        items:[{
          getClass: function(v, meta, rec) {  // Or return a class from a function
            this.items[0].tooltip = rec.get('comments');
            return 'info-col';
          },
          handler: function(grid, rowIndex, colIndex) {
            return false;
          }
        }]
      }
      ],
      loadMask: true,
      stripeRows: true,
      store: Ext.create("Ext.data.Store",{
        autoLoad: true,
        proxy:{
          type:'ajax',
          url: '/erp_products/erp_app/desktop/product_manager/prices/'+config.productTypeId,
          reader:{
            root: 'prices',
            type:'json'
          }
        },
        fields:[{
          name:'price',
          type:'decimal'
        }, 'currency', 'currency_display', 'from_date', 'thru_date', 'description','comments','pricing_plan_id']
      })
    });

    this.addEditPriceBtn = Ext.create("Ext.button.Button",{
      scope:this,
      text:'Add Price',
      handler:function(btn){
        var formPanel = btn.findParentByType('form');
        var basicForm = formPanel.getForm();

        basicForm.submit({
          reset:true,
          success:function(form, action){
            var obj =  Ext.decode(action.response.responseText);
            if(obj.success){
              self.addEditPriceBtn.setText('Add Price');
              self.cancelBtn.hide();
              Ext.getCmp('productListPanel').loadProducts();
              self.pricesGridPanel.getStore().load();
            }
            else{
              Ext.Msg.alert("Error", 'Error creating price');
            }
          },
          failure:function(form, action){
            Ext.Msg.alert("Error", 'Error creating price');
          }
        });
      }
    });

    this.cancelBtn = Ext.create("Ext.button.Button",{
      text:'Cancel',
      hidden:true,
      handler:function(btn){
        var formPanel = btn.findParentByType('form');
        var basicForm = formPanel.getForm();
        basicForm.reset();
        self.addEditPriceBtn.setText('Add Price');
        self.cancelBtn.hide();
      }
    });

    this.addPriceFormPanel = Ext.create("Ext.form.Panel",{
      layout:'anchor',
      collapsible:true,
      split:true,
      height:175,
      frame:true,
      region:'south',
      buttonAlign:'center',
      bodyStyle:'padding:5px 5px 0',
      url:'/erp_products/erp_app/desktop/product_manager/new_and_update_price',
      items: [
      {
        xtype:'textfield',
        width:400,
        name:'description',
        fieldLabel:'Description'
      },
      {
        layout:'column',
        xtype:'container',
        frame:false,
        border:false,
        defaults:{
          columnWidth:0.25,
          border:false,
          frame:false,
          xtype:'container',
          bodyStyle:'padding:0 18px 0 0'
        },
        items:[{
          items:[
          {
            fieldLabel:'Price',
            xtype:'numberfield',
            width:200,
            layout:'anchor',
            allowBlank:false,
            name:'price'
          }
          ]
        },
        {
          items:[
          {
            fieldLabel:'Currency',
            xtype:'combo',
            width:200,
            id : 'call_center_party_country',
            allowBlank : false,
            store :Ext.create("Ext.data.Store",{
              autoLoad: true,
              proxy:{
                type:'ajax',
                url: '/erp_products/erp_app/desktop/product_manager/currencies',
                reader:{
                  root: 'currencies',
                  type:'json'
                }
              },
              fields: [
              {
                name:'internal_identifier'
              },
              {
                name:'id'
              }
              ]
            }),
            hiddenName: 'currency',
            hiddenField: 'currency',
            valueField: 'id',
            displayField: 'internal_identifier',
            forceSelection : true,
            triggerAction : 'all',
            name:'currency'
          }
          ]
        },
        {
          items:[
          {
            fieldLabel:'From Date',
            xtype:'datefield',
            width:200,
            allowBlank:false,
            name:'from_date'
          }
          ]
        },
        {
          items:[
          {
            fieldLabel:'Thru Date',
            xtype:'datefield',
            width:200,
            allowBlank:false,
            name:'thru_date'
          }
          ]
        }]
      },
      {
        xtype:'textarea',
        height:50,
        width:400,
        name:'comments',
        fieldLabel:'Comments'
      },
      {
        xtype:'hidden',
        name:'product_type_id',
        value:config.productTypeId
      },
      {
        xtype:'hidden',
        name:'pricing_plan_id'
      }
      ],
      buttons:[
      this.addEditPriceBtn,
      this.cancelBtn
      ]
    });

    config = Ext.apply({
      title:'Pricing',
      layout:'border',
      items:[this.pricesGridPanel,this.addPriceFormPanel]
    }, config);

    Compass.ErpApp.Desktop.Applications.ProductManager.ProductPricingPanel.superclass.constructor.call(this, config);
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

    Compass.ErpApp.Desktop.Applications.ProductManager.ProductImagesPanel.superclass.constructor.call(this, config);
  }
});

//
//Inventory Management
//

Ext.define("Compass.ErpApp.Desktop.Applications.ProductManager.InventoryFormPanel",{
  extend:"Ext.form.Panel",
  alias:'widget.productmanager_inventoryformpanel',
  initComponent: function() {
    Compass.ErpApp.Desktop.Applications.ProductManager.InventoryFormPanel.superclass.initComponent.call(this, arguments);
  },

  constructor : function(config) {
    config = Ext.apply({
      title:'Inventory',
      frame:true,
      buttonAlign:'left',
      bodyStyle:'padding:5px 5px 0',
      url:'/erp_products/erp_app/desktop/product_manager/update_inventory',
      items:[
      {
        fieldLabel:'SKU #',
        xtype:'textfield',
        allowBlank:true,
        name:'sku'
      },{
        fieldLabel:'# Available',
        xtype:'numberfield',
        allowBlank:false,
        name:'number_available'
      },
      {
        xtype:'hidden',
        name:'product_type_id',
        value:config.productTypeId
      },
      ],
      buttons:[
      {
        text:'Update',
        handler:function(btn){
          var formPanel = btn.findParentByType('form');
          var basicForm = formPanel.getForm();

          basicForm.submit({
            reset:false,
            success:function(form, action){
              var obj = Ext.decode(action.response.responseText);
              if(obj.success){
                Ext.getCmp('productListPanel').loadProducts();
              }
              else{
                Ext.Msg.alert("Error", 'Error creating price');
              }
            },
            failure:function(form, action){
              Ext.Msg.alert("Error", 'Error creating price');
            }
          });
        }
      }
      ]
    }, config);

    Compass.ErpApp.Desktop.Applications.ProductManager.InventoryFormPanel.superclass.constructor.call(this, config);
  }
});

//
//Add product window
//

Ext.define("Compass.ErpApp.Desktop.Applications.ProductManager.AddProductWindow",{
  extend:"Ext.window.Window",
  alias:'widget.productmanager_addproductwindow',
  initComponent: function() {
    Compass.ErpApp.Desktop.Applications.ProductManager.AddProductWindow.superclass.initComponent.call(this, arguments);
  },

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

    Compass.ErpApp.Desktop.Applications.ProductManager.AddProductWindow.superclass.constructor.call(this, config);
  }
});

//
//Update product window
//

Ext.define("Compass.ErpApp.Desktop.Applications.ProductManager.UpdateProductWindow",{
  extend:"Ext.window.Window",
  alias:'widget.productmanager_updateproductwindow',
  initComponent: function() {
    Compass.ErpApp.Desktop.Applications.ProductManager.UpdateProductWindow.superclass.initComponent.call(this, arguments);
  },

  constructor : function(config) {
    var self = this;
    var activeTab = config['activeTab'] | 0

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
      },
      {
        xtype:'productmanager_productpricingpanel',
        productTypeId:config.productTypeId
      },
      {
        xtype:'productmanager_inventoryformpanel',
        productTypeId:config.productTypeId,
        listeners:{
          'activate':function(panel){
            var self = this;
            Ext.Ajax.request({
              url: '/erp_products/erp_app/desktop/product_manager/inventory/'+panel.initialConfig['productTypeId'],
              success: function(response) {
                var obj = Ext.decode(response.responseText);
                self.getForm().setValues(obj);
              },
              failure: function(response) {
                Ext.Msg.alert('Error', 'Error loading inventory.');
              }
            });
          }
        }
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
          comp.query('tabpanel')[0].setActiveTab(activeTab);
        }
      }
    }, config);

    Compass.ErpApp.Desktop.Applications.ProductManager.UpdateProductWindow.superclass.constructor.call(this, config);
  }
});