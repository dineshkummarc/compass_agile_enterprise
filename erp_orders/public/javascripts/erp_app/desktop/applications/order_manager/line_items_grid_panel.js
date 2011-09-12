Ext.define("Compass.ErpApp.Desktop.Applications.OrderManager.OrderLineItemsGridPanel",{
    extend:"Ext.grid.Panel",
    alias:'widget.desktopordermanagement_orderlineitemsgridpanel',
    initComponent : function(){
        this.bbar = new Ext.PagingToolbar({
            pageSize: 10,
            store:this.store,
            displayInfo: true,
            displayMsg: '{0} - {1} of {2}',
            emptyMsg: "Empty"
        });

        Compass.ErpApp.Desktop.Applications.OrderManager.OrderLineItemsGridPanel.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        var store = Ext.create("Ext.data.Store",{
            proxy:{
                type:'ajax',
                url: '/erp_app/desktop/order_manager/line_items',
                reader:{
                    type:'json',
                    root: 'lineItems',
                    idProperty:'id'
                }
            },
            totalProperty: 'totalCount',
            extraParams:{
                order_id:null
            },
            fields:[
            'product',
            'quantity',
            'sku',
            {
                name:'price',
                type:'decimal'
            },
            'currency_display',
            'id'
            ]
        });

        config = Ext.apply({
            layout:'fit',
            columns: [
            {
                header:'Product',
                sortable: true,
                dataIndex: 'product'
            },
            {
                header:'SKU',
                sortable: true,
                dataIndex: 'sku'
            },
            {
                header:'Quantity',
                sortable: true,
                dataIndex: 'quantity'
            },
            {
                header:'Price',
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

            }
            ],
            loadMask: true,
            autoScroll:true,
            stripeRows: true,
            store:store,
            viewConfig:{
                forceFit:true
            },
            listeners:{
                activate:function(grid){
                    var layout = grid.findParentByType('organizer_orderslayout');
                    if(!Compass.ErpApp.Utility.isBlank(layout.orderId)){
                        var store = grid.getStore();
                        store.proxy.extraParams.order_id = layout.orderId;
                        store.load();
                    }
                }
            }
        }, config);

        Compass.ErpApp.Desktop.Applications.OrderManager.OrderLineItemsGridPanel.superclass.constructor.call(this, config);
    }
});