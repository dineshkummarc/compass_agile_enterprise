Compass.ErpApp.Desktop.Applications.OrderManager.PaymentsGridPanel = Ext.extend(Ext.grid.GridPanel, {
    constructor : function(config) {
        var store = new Ext.data.JsonStore({
            url: '/erp_app/desktop/order_manager/payments',
            root: 'payments',
            baseParam:{
                order_id:null
            },
            fields:[
            'authorization',
            'status',
            'created_at',
            {
                name:'amount',
                type:'decimal'
            },
            'currency_display',
            'id',
            'success'
            ]
        });

        config = Ext.apply({
            layout:'fit',
            columns: [
            {
                header:'Authorization Number',
                sortable: true,
                dataIndex: 'authorization'
            },
            {
                header:'Status',
                sortable: true,
                dataIndex: 'status'
            },
            {
                header:'Successful',
                sortable: true,
                dataIndex: 'success'
            },
            {
                header:'Amount',
                sortable: true,
                dataIndex: 'amount',
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
                header: 'Created At',
                sortable: true,
                dataIndex: 'created_at',
                renderer: Ext.util.Format.dateRenderer('m/d/Y  H:i:s')
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

        Compass.ErpApp.Desktop.Applications.OrderManager.PaymentsGridPanel.superclass.constructor.call(this, config);
    }
});

Ext.reg('desktopordermanagement_paymentsgridpanel', Compass.ErpApp.Desktop.Applications.OrderManager.PaymentsGridPanel);
