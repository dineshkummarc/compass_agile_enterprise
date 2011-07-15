Ext.define("Compass.ErpApp.Desktop.Applications.OrderManager.OrdersGridPanel",{
    extend:"Ext.grid.Panel",
    alias:'widget.ordermanager_ordersgridpanel',
    deleteOrder : function(rec){
        var self = this;
        Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this order?', function(btn){
            if(btn == 'no'){
                return false;
            }
            else
            {
                var conn = new Ext.data.Connection();
                conn.request({
                    url: './order_manager/delete/'+rec.get('id'),
                    success: function(response) {
                        var obj =  Ext.decode(response.responseText);
                        if(obj.success){
                            self.getStore().load();
                        }
                        else{
                            Ext.Msg.alert('Error', 'Error deleting order.');
                        }
                    },
                    failure: function(response) {
                        Ext.Msg.alert('Error', 'Error deleting order.');
                    }
                });
            }
        });
    },

    initComponent : function(){
        this.bbar = Ext.create("Ext.PagingToolbar",{
            pageSize: this.initialConfig['pageSize'] || 50,
            store:this.store,
            displayInfo: true,
            displayMsg: '{0} - {1} of {2}',
            emptyMsg: "Empty"
        });

        Compass.ErpApp.Desktop.Applications.OrderManager.OrdersGridPanel.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        var store = Ext.create("Ext.data.Store",{
            autoLoad: true,
            proxy:{
                type:'ajax',
                url: './order_manager',
                reader:{
                    type:'json',
                    root: 'orders'
                }
            },
            extraParams:{
                order_number:null
            },
            totalProperty: 'totalCount',
            fields:['total_price','order_number', 'status', 'first_name', 'last_name', 'email','phone','id','created_at']
        });

        config = Ext.apply({
            layout:'fit',
            columns: [
            {
                header:'Order Number',
                sortable: true,
                dataIndex: 'order_number'
            },
            {
                header:'Status',
                sortable: true,
                dataIndex: 'status'
            },
            {
                header:'Total Price',
                sortable: true,
                dataIndex: 'total_price'
            },
            {
                header:'First Name',
                sortable: true,
                width:150,
                dataIndex: 'first_name'
            },
            {
                header:'Last Name',
                sortable: true,
                width:150,
                dataIndex: 'last_name'
            },
            {
                header:'Email',
                sortable: true,
                dataIndex: 'email'
            },
            {
                header:'Phone',
                sortable: true,
                dataIndex: 'phone'
            },
            {
                header:'Created At',
                sortable: true,
                dataIndex: 'created_at',
                width:150,
                renderer: Ext.util.Format.dateRenderer('m/d/Y  H:i:s')
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
                        grid.deleteOrder(rec);
                    }
                }]
            }
            ],
            store:store,
            loadMask: true,
            autoScroll:true,
            stripeRows: true,
            tbar:{
                items:[
                '<span class="x-btn-inner">Order Number:</span>',
                {
                    xtype:'numberfield',
                    hideLabel:true,
                    id:'orderNumberSearchTextField'
                },
                {
                    text:'Search',
                    iconCls:'icon-search',
                    handler:function(btn){
                        var orderNumber = Ext.getCmp('orderNumberSearchTextField').getValue();
                        btn.findParentByType('ordermanager_ordersgridpanel').store.proxy.extraParams.order_number = orderNumber;
                        btn.findParentByType('ordermanager_ordersgridpanel').store.load();
                    }
                },
                '|',
                {
                    text: 'All',
                    xtype:'button',
                    iconCls: 'icon-eye',
                    handler: function(button) {
                        btn.findParentByType('ordermanager_ordersgridpanel').store.proxy.extraParams.order_number = null;
                        btn.findParentByType('ordermanager_ordersgridpanel').store.load();
                    }
                },
                ]
            }
        }, config);

        Compass.ErpApp.Desktop.Applications.OrderManager.OrdersGridPanel.superclass.constructor.call(this, config);
    }
});