Compass.ErpApp.Desktop.Applications.ProductManager.ProductsPanel = Ext.extend(Ext.Panel, {

    loadProducts : function(){
        this.productsDataView.getStore().reload();
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
                    url: './product_manager/delete/'+id,
                    success: function(response) {
                        var obj =  Ext.util.JSON.decode(response.responseText);
                        if(obj.success){
                            self.productsDataView.getStore().reload();
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

        this.productsDataView = new Ext.DataView({
            autoDestroy:true,
            itemSelector: 'tr.product-wrap',
            style:'overflow:auto',
            multiSelect: true,
            plugins: new Ext.DataView.DragSelector({
                dragSafe:true
            }),
            store: new Ext.data.JsonStore({
                url: './product_manager/',
                autoLoad: true,
                root: 'products',
                id:'id',
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
                'contextmenu':function(dataView, index, node, e){
                    e.stopEvent();
                    var contextMenu = new Ext.menu.Menu({
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
                'click':function(dataView, index, node, e){
                    e.stopEvent();
                    var id = self.productsDataView.getStore().getAt(index).get('id');
                    var win = new Compass.ErpApp.Desktop.Applications.ProductManager.UpdateProductWindow({
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
                        var window = new Compass.ErpApp.Desktop.Applications.ProductManager.AddProductWindow({
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

Ext.reg('productmanagement_productspanel', Compass.ErpApp.Desktop.Applications.ProductManager.ProductsPanel);