Ext.ns("Compass.ErpApp.Organizer.Applications.OrderManagement");

Compass.ErpApp.Organizer.Applications.OrderManagement.Layout = Ext.extend(Ext.Panel, (function() {
    //private member orderId
    var orderId = null;

    return{
        constructor : function(config) {
            var southPanel = new Ext.Panel({
                layout:'fit',
                region:'south',
                height:300,
                collapsible:true,
                border:false,
                items:[config['southComponent']]
            });

            var centerPanel = new Ext.Panel({
                layout:'fit',
                region:'center',
                autoScroll:true,
                items:[config['centerComponent']]
            })

            config = Ext.apply({
                layout:'border',
                frame: false,
                autoScroll:true,
                region:'center',
                items:[
                    centerPanel,
                    southPanel
                ]

            }, config);
            Compass.ErpApp.Organizer.Applications.OrderManagement.Layout.superclass.constructor.call(this, config);
        },

        /**
         * set the private member orderId
         * @param {Integer} orderId
         */
        setOrderId : function(orderId){
            this.orderId = orderId;
        },


        loadOrderDetails : function(orderId){
            if(orderId == null){
                Ext.Msg.alert('Error', 'Order must be selected.');
            }
            else{
                this.orderId = orderId;
                var tabPanel = this.findByType('tabpanel')[0];
            
                var orderLineItemsGrid = tabPanel.findByType('organizerordermanagement_orderlineitemsgridpanel')[0];
                orderLineItemsGrid.getStore().load({params:{order_id:this.orderId}});

                tabPanel.setActiveTab(0);
            }
        },

        loadRemoteData:function(){
            this.orderId = null;
            var ordersGridPanel = this.findByType('ordermanager_ordersgridpanel')[0]
            ordersGridPanel.getStore().load();
        }
    };
}())
);

Ext.reg('organizer_orderslayout', Compass.ErpApp.Organizer.Applications.OrderManagement.Layout);

Compass.ErpApp.Organizer.Applications.OrderManagement.Base = function(config){

    //setup extensions
    Compass.ErpApp.Organizer.Applications.OrderManagement.loadExtensions();

    var menuTreePanel = {
        xtype:'defaultmenutree',
        title:'Order Management',
        menuRootIconCls:'icon-content',
        rootNodeTitle:'Menu',
        treeConfig:{
            loader:{
                dataUrl:'./order_management/menu'
            }
        }
    };

    var southTabPanel = {
        xtype:'tabpanel',
        items:[{
                xtype:'organizerordermanagement_orderlineitemsgridpanel',
                title:'Line Items'
            },{
                xtype:'organizerordermanagement_paymentsgridpanel',
                title:'Payments'
            }]
    }
    
    var layout = {
        id:'orders_layout',
        xtype:'organizer_orderslayout',
        centerComponent:{
            id:'orders_grid',
            xtype:'ordermanager_ordersgridpanel',
            selModel:new Ext.grid.RowSelectionModel({
                listeners:{
                    'rowselect':function(selModel, rowIndex, record){
                        var id = record.get("id");
                        var layout = selModel.grid.findParentByType('organizer_orderslayout');
                        layout.loadOrderDetails(id);
                    }
                }
            })
        },
        southComponent:southTabPanel
    };

    this.setup = function(){
        config['organizerLayout'].addApplication(menuTreePanel,[layout]);
    };

    this.loadRemoteData = function(){
        
    }

};

