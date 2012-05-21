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

  constructor : function(config) {
    var self = this;
    var productTypeId = Compass.ErpApp.Desktop.Applications.ProductManager.selectedProductTypeId;

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
          url: '/erp_products/erp_app/desktop/product_manager/prices/'+productTypeId,
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
        value:productTypeId
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

    this.callParent([config]);
  }
});

Compass.ErpApp.Desktop.Applications.ProductManager.widgets.push({xtype:'productmanager_productpricingpanel'});
