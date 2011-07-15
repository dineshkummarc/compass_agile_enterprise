Ext.define("Compass.ErpApp.Organizer.Applications.OrderManagement.OrdersGridPanel",{
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
                    url: '/erp_app/desktop/order_manager/delete/'+rec.get('id'),
                    success: function(response) {
                        var obj =  Ext.util.JSON.decode(response.responseText);
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

        Compass.ErpApp.Organizer.Applications.OrderManagement.OrdersGridPanel.superclass.initComponent.call(this, arguments);
    },

    constructor : function(config) {
        var store = Ext.create("Ext.data.Store",{
            proxy:{
               type:'ajax',
               url: '/erp_app/desktop/order_manager',
               reader:{
                   type:'json',
                   root: 'orders',
               }
            },
            totalProperty: 'totalCount',
            idProperty: 'id',
            fields:[
            'total_price',
            'order_number',
            'status',
            'first_name',
            'last_name',
            'email',
            'phone',
            'id',
            'created_at',
            'buyer_party_id'
            ]
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
                width:150,
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
                header:'Payor Info',
                align:'center',
                width:100,
                items:[{
                    icon:'/images/icons/about/about_16x16.png',
                    tooltip:'View Payor Info',
                    handler :function(grid, rowIndex, colIndex){
                        var rec = grid.getStore().getAt(rowIndex);
                        var buyerPartyId = rec.get('buyer_party_id');

                        if(Compass.ErpApp.Utility.isBlank(buyerPartyId)){
                            Ext.Msg.alert('Status', 'No Buyer data has been collected yet.')
                            return false;
                        }

                        var individualsGrid = Ext.getCmp('individualSearchGrid');

                        var index = individualsGrid.getStore().find("id", buyerPartyId);
                        var record = individualsGrid.getStore().getAt(index);
                        individualsGrid.getSelectionModel().selectRecords([record], false);
                        Compass.Component.UserApp.Util.setActiveCenterItem('individuals_search_grid');
                        var individualsTabPanel = Ext.getCmp('individualsTabPanel');
                        var ordersGridPanel = individualsTabPanel.query('ordermanager_ordersgridpanel')[0];
                        individualsTabPanel.setActiveTab(ordersGridPanel.id);
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
                        grid.deleteOrder(rec);
                    }
                }]
            }
            ],
            loadMask: true,
            autoScroll:true,
            stripeRows: true,
            store:store,
            tbar:{
                items:[
                    '<span style="color:white;font-weight:bold;">Order Number:</span>',
                    {
                        xtype:'numberfield',
                        fieldLabel:'Order Number',
                        id:'orderNumberSearchTextField'
                    },
                    {
                        text:'Search',
                        iconCls:'icon-search',
                        handler:function(btn){
                            var orderNumber = Ext.getCmp('orderNumberSearchTextField').getValue();
                            var store = btn.findParentByType('ordermanager_ordersgridpanel').getStore();
                            store.load({params:{order_number:orderNumber}});
                        }
                    }
                ]
            }
        }, config);

        Compass.ErpApp.Organizer.Applications.OrderManagement.OrdersGridPanel.superclass.constructor.call(this, config);
    }
});