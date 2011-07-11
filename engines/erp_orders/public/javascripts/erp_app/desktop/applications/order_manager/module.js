Ext.ns("Compass.ErpApp.Desktop.Applications");

Compass.ErpApp.Desktop.Applications.OrderManager = Ext.extend(Ext.app.Module, {
    id:'order_manager-win',
    init : function(){
        this.launcher = {
            text: 'Orders',
            iconCls:'icon-package',
            handler : this.createWindow,
            scope: this
        }
    },
    createWindow : function(){
        var desktop = this.app.getDesktop();
        var win = desktop.getWindow('order_manager');
        if(!win){
            var tabPanel = new Ext.TabPanel({
                region:'south',
                height:250,
                collapsible:true,
                border:false,
                xtype:'tabpanel',
                items:[{
                    xtype:'desktopordermanagement_orderlineitemsgridpanel',
                    title:'Line Items',
                    listeners:{
                        activate:function(grid){
                            var orderId = Ext.getCmp('orders_layout').findByType('ordermanager_ordersgridpanel')[0].orderId;
                            if(!Compass.ErpApp.Utility.isBlank(Compass.ErpApp.Desktop.Applications.OrderManager.orderId)){
                                var store = grid.getStore();
                                store.setBaseParam('order_id', Compass.ErpApp.Desktop.Applications.OrderManager.orderId);
                                store.load();
                            }
                        }
                    }
                },{
                    xtype:'desktopordermanagement_paymentsgridpanel',
                    title:'Payments',
                    listeners:{
                        activate:function(grid){
                            var orderId = Ext.getCmp('orders_layout').findByType('ordermanager_ordersgridpanel')[0].orderId;
                            if(!Compass.ErpApp.Utility.isBlank(Compass.ErpApp.Desktop.Applications.OrderManager.orderId)){
                                var store = grid.getStore();
                                store.setBaseParam('order_id', Compass.ErpApp.Desktop.Applications.OrderManager.orderId);
                                store.load();
                            }
                        }
                    }
                }]
            });

            var layout = {
                id:'orders_layout',
                layout:'border',
                frame: false,
                autoScroll:true,
                items:[{
                    region:'center',
                    xtype:'ordermanager_ordersgridpanel',
                    selModel:new Ext.grid.RowSelectionModel({
                        listeners:{
                            'rowselect':function(selModel, rowIndex, record){
                                Compass.ErpApp.Desktop.Applications.OrderManager.orderId = record.get("id");
                                tabPanel.findByType('desktopordermanagement_orderlineitemsgridpanel')[0].getStore().load();
                                tabPanel.setActiveTab(0);
                            }
                        }
                    })
                },
                tabPanel
                ]
            }

            win = desktop.createWindow({
                id: 'order_manager',
                title:'Orders',
                width:1050,
                height:550,
                iconCls: 'icon-package',
                shim:false,
                animCollapse:false,
                constrainHeader:true,
                layout: 'fit',
                items:[layout]
            });
        }
        win.show();
    }
});

