Compass.ErpApp.Widgets.ShoppingCart = {
    addShoppingCart:function(){
        var addShoppingCartWidget = Ext.create("Ext.window.Window",{
            layout:'fit',
            width:300,
            title:'Add Shopping Cart Widget',
            height:130,
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
                    xtype: 'combo',
                    forceSelection:true,
                    store: [
                    [':price_summary','Price Summary'],
                    [':cart_items','Cart Items'],
                    ],
                    fieldLabel: 'Widget View',
                    value:':price_summary',
                    name: 'widgetLayout',
                    allowBlank: false,
                    triggerAction: 'all',
                    listeners:{
                        change:function(field, newValue, oldValue){
                            var basicForm = field.findParentByType('form').getForm();
                            var cartItemsUrlField = basicForm.findField('cartItemsUrl');
                            var productsUrlField = basicForm.findField('productsUrl');
                            if(newValue == ':price_summary'){
                                cartItemsUrlField.show();
                                productsUrlField.hide();
                                cartItemsUrlField.setValue('/cart-summary');
                            }
                            else{
                                productsUrlField.show();
                                cartItemsUrlField.hide();
                                productsUrlField.setValue('/products');
                            }
                        }
                    }
                },
                {
                    xtype:'textfield',
                    fieldLabel:'Cart Items Url',
                    name:'cartItemsUrl',
                    hidden:false,
                    value:'/cart-items'
                },
                {
                    xtype:'textfield',
                    fieldLabel:'Products Url',
                    name:'productsUrl',
                    value:'/products',
                    hidden:true
                },
                ]
            }),
            buttons: [{
                text:'Submit',
                listeners:{
                    'click':function(button){
                        var window = button.findParentByType('window');
                        var formPanel = window.query('form')[0];
                        var basicForm = formPanel.getForm();
                        var action = basicForm.findField('widgetLayout').getValue();

                        var data = {action:action};
                        if(action == ':price_summary'){
                            data.symbol = 'cart_items_url';
                            data.url = basicForm.findField('cartItemsUrl').getValue();
                        }
                        else{
                            data.symbol = 'products_url';
                            data.url = basicForm.findField('productsUrl').getValue();
                        }

                        var tpl = new Ext.XTemplate("<%= render_widget :shopping_cart,\n",
                                                    "   :action => {action},\n",
                                                    "   :params => {:{symbol} => '{url}'} %>");

                        //add rendered template to center region editor
                        Ext.getCmp('knitkitCenterRegion').addContentToActiveCodeMirror(tpl.apply(data));
                        addShoppingCartWidget.close();
                    }
                }
            },{
                text: 'Close',
                handler: function(){
                    addShoppingCartWidget.close();
                }
            }]

        });
        addShoppingCartWidget.show();
    }
}

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name:'Shopping Cart',
    iconUrl:'/images/icons/shoppingcart/shoppingcart_48x48.png',
    onClick:Compass.ErpApp.Widgets.ShoppingCart.addShoppingCart
});