Ext.define("Compass.ErpApp.Organizer.Applications.OrderManagement.Layout",{
    extend:"Ext.panel.Panel",
    alias:'widget.organizer_orderslayout',
    //private member orderId
    orderId:null,
    constructor : function(config) {
        var southPanel = Ext.create("Ext.panel.Panel",{
            layout:'fit',
            region:'south',
            height:300,
            collapsible:true,
            border:false,
            items:[config['southComponent']]
        });

        var centerPanel = Ext.create("Ext.panel.Panel",{
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
            var tabPanel = this.query('tabpanel')[0];
            
            var orderLineItemsGrid = tabPanel.query('organizerordermanagement_orderlineitemsgridpanel')[0];
            orderLineItemsGrid.getStore().load({
                params:{
                    order_id:this.orderId
                }
            });

            tabPanel.setActiveTab(0);
        }
    },

    loadRemoteData:function(){
        this.orderId = null;
        var ordersGridPanel = this.query('ordermanager_ordersgridpanel')[0]
        ordersGridPanel.getStore().load();
    }

});

Compass.ErpApp.Organizer.Applications.OrderManagement.Base = function(config){

    //setup extensions
    Compass.ErpApp.Organizer.Applications.OrderManagement.loadExtensions();

    var treeMenuStore = Ext.create('Compass.ErpApp.Organizer.DefaultMenuTreeStore', {
        url:'/erp_orders/erp_app/organizer/order_management/menu',
        rootText:'Menu',
        rootIconCls:'icon-content'
    });

    var menuTreePanel = {
        xtype:'defaultmenutree',
        title:'Order Management',
        store:treeMenuStore
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
            listeners:{
                'itemclick':function(view, record, item, index, e, options){
                    var id = record.get("id");
                    var layout = view.findParentByType('organizer_orderslayout');
                    layout.loadOrderDetails(id);
                }
            }
        },
        southComponent:southTabPanel
    };

    this.setup = function(){
        config['organizerLayout'].addApplication(menuTreePanel,[layout]);
    };

    this.loadRemoteData = function(){
        
    }

};

