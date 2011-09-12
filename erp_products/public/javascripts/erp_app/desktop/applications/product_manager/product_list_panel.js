Ext.define("Compass.ErpApp.Desktop.Applications.ProductManager.ProductsPanel",{
    extend:"Ext.panel.Panel",
    alias:'widget.productmanagement_productspanel',
    loadProducts : function(){
        this.productsDataView.getStore().load();
    },

    deleteProduct : function(id){
        var self = this;
        Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this product?', function(btn){
            if(btn == 'no'){
                return false;
            }
            else
            {
                var conn = new Ext.data.Connection();
                conn.request({
                    url: '/erp_products/erp_app/desktop/product_manager/delete/'+id,
                    success: function(response) {
                        var obj =  Ext.decode(response.responseText);
                        if(obj.success){
                            self.productsDataView.getStore().load();
                        }
                        else{
                            Ext.Msg.alert('Error', 'Error deleting product.');
                        }
                    },
                    failure: function(response) {
                        Ext.Msg.alert('Error', 'Error deleting product.');
                    }
                });
            }
        });
    },

    initComponent: function() {
        Compass.ErpApp.Desktop.Applications.ProductManager.ProductsPanel.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        var self = this;

        this.productsDataView = Ext.create("Ext.view.View",{
            autoDestroy:true,
            itemSelector: 'tr.product-wrap',
            style:'overflow:auto',
            store: Ext.create("Ext.data.Store",{
                autoLoad: true,
                proxy:{
                    type:'ajax',
                    url: '/erp_products/erp_app/desktop/product_manager/',
                    reader:{
                        root: 'products',
                        type:'json'
                    }
                },
                fields:['imageUrl', 'id', 'title', 'available', 'sold','price','sku']
            }),
            tpl: new Ext.XTemplate(
                '<table id="products-view">',
                '<thead>',
                '<tr>',
                '<td>Product</td>',
                '<td># Available</td>',
                '<td># Sold</td>',
                '</tr>',
                '</thead>',
                '<tbody>',
                '<tpl for=".">',
                '<tr class="product-wrap">',
                '<td>',
                '<div><img src="{imageUrl}" /></div>',
                '<div>',
                '<span>{title}</span><br/>',
                '<span>{price}</span><br/>',
                '<span>SKU # {sku}</span>',
                '</div>',
                '</td>',
                '<td>{available}</td>',
                '<td>{sold}</td>',
                '</tr>',
                '</tpl>',
                '</tbody>',
                '</table>'
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
                                var id = self.productsDataView.getStore().getAt(index).get('id');
                                self.deleteProduct(id);
                            }
                        }
                        ]
                    });
                    contextMenu.showAt(e.xy);
                },
                'itemclick':function(view, record, htmlitem, index, e, options){
                    e.stopEvent();
                    var id = self.productsDataView.getStore().getAt(index).get('id');
                    var win = Ext.create("Compass.ErpApp.Desktop.Applications.ProductManager.UpdateProductWindow",{
                        productTypeId:id
                    });
                    win.show();
                }
            }
        });

        config = Ext.apply({
            id:'productListPanel',
            border:false,
            autoDestroy:true,
            margins: '5 5 5 0',
            autoScroll:true,
            layout:'fit',
            items:[this.productsDataView],
            tbar:{
                items:[
                {
                    text:'Add Product',
                    iconCls:'icon-add',
                    handler:function(btn){
                        var window = Ext.create("Compass.ErpApp.Desktop.Applications.ProductManager.AddProductWindow",{
                            productListPanel:self
                        });
                        window.show();
                    }
                }
                ]
            }
        }, config);

        Compass.ErpApp.Desktop.Applications.ProductManager.ProductsPanel.superclass.constructor.call(this, config);
    }

});