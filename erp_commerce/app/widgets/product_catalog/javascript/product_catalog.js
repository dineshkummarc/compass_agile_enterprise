Compass.ErpApp.Widgets.ProductCatalog = {
    add:function(){
        var addProductCatalogWidgetWindow = Ext.create("Ext.window.Window",{
            layout:'fit',
            width:300,
            title:'Add Product Catalog Widget',
            height:100,
            buttonAlign:'center',
            items: Ext.create("Ext.form.Panel",{
                labelWidth: 100,
                frame:false,
                bodyStyle:'padding:5px 5px 0',
                defaults: {
                    width: 225
                },
                items: [
                {
                    xtype:'textfield',
                    fieldLabel:'Cart Items Url',
                    name:'cartItemsUrl',
                    hidden:false,
                    value:'/cart-items'
                }
                ]
            }),
            buttons: [{
                text:'Submit',
                handler:function(button){
                    var window = button.findParentByType('window');
                    var formPanel = window.query('form')[0];
                    var basicForm = formPanel.getForm();
                    var cartItemsUrl = basicForm.findField('cartItemsUrl').getValue();
                    var data = {
                        cartItemsUrl:cartItemsUrl
                    };

                    var tpl = new Ext.XTemplate("<%= render_widget :product_catalog,\n",
                        "   :action => :index,\n",
                        "   :params => {:cart_items_url => '{cartItemsUrl}'} %>");

                    //add rendered template to center region editor
                    Ext.getCmp('knitkitCenterRegion').addContentToActiveCodeMirror(tpl.apply(data));
                    addProductCatalogWidgetWindow.close();
                }
            },
            {
                text: 'Close',
                handler: function(){
                    addProductCatalogWidgetWindow.close();
                }
            }]

        });
        addProductCatalogWidgetWindow.show();
    }
}

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name:'Product Catalog',
    iconUrl:'/images/icons/product/product_48x48.png',
    onClick:Compass.ErpApp.Widgets.ProductCatalog.add
});