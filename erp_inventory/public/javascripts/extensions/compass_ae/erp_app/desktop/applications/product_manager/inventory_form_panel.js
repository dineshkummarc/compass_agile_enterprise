//
//Inventory Management
//

Ext.define("Compass.ErpApp.Desktop.Applications.ProductManager.InventoryFormPanel",{
    extend:"Ext.form.Panel",
    alias:'widget.productmanager_inventoryformpanel',

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
                value:Compass.ErpApp.Desktop.Applications.ProductManager.selectedProductTypeId
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

        this.callParent([config]);
    }
});

Compass.ErpApp.Desktop.Applications.ProductManager.widgets.push({
    xtype:'productmanager_inventoryformpanel',
    listeners:{
        'activate':function(panel){
            var self = this;
            Ext.Ajax.request({
                url: '/erp_products/erp_app/desktop/product_manager/inventory/'+Compass.ErpApp.Desktop.Applications.ProductManager.selectedProductTypeId,
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
});

