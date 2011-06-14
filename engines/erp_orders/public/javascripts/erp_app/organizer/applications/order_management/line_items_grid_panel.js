Compass.ErpApp.Organizer.Applications.OrderManagement.OrderLineItemsGridPanel = Ext.extend(Ext.grid.GridPanel, {
    initComponent : function(){
        this.bbar = new Ext.PagingToolbar({
            pageSize: 10,
            store:this.store,
            displayInfo: true,
            displayMsg: '{0} - {1} of {2}',
            emptyMsg: "Empty"
        });

        Compass.ErpApp.Organizer.Applications.OrderManagement.OrderLineItemsGridPanel.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        var store = new Ext.data.JsonStore({
            url: '/erp_app/desktop/order_manager/line_items',
            root: 'lineItems',
            totalProperty: 'totalCount',
            baseParam:{
                order_id:null
            },
            remoteSort: false,
            idProperty:'id',
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
                        store.setBaseParam('order_id', layout.orderId);
                        store.load();
                    }
                }
            }
        }, config);

        Compass.ErpApp.Organizer.Applications.OrderManagement.OrderLineItemsGridPanel.superclass.constructor.call(this, config);
    }
});

Ext.reg('organizerordermanagement_orderlineitemsgridpanel', Compass.ErpApp.Organizer.Applications.OrderManagement.OrderLineItemsGridPanel);
