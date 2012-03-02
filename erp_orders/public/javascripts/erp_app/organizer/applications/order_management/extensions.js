Ext.define("Compass.ErpApp.Organizer.Applications.OrderManagement.PartyOrdersTab",{
  extend:"Compass.ErpApp.Organizer.Applications.OrderManagement.OrdersGridPanel",
  alias:'widget.partyorderstab',
    title:'Orders',
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
      header:'Order Details',
      align:'center',
      width:100,
      items:[{
        icon:'/images/icons/about/about_16x16.png',
        tooltip:'View Order Details',
        handler :function(grid, rowIndex, colIndex){
          var rec = grid.getStore().getAt(rowIndex);
          var orderId = rec.get('id');

          var ordersLayout = Ext.getCmp('orders_layout');
          ordersLayout.loadOrderDetails(orderId);
          var ordersGridPanel = ordersLayout.query('ordermanager_ordersgridpanel')[0];
          ordersGridPanel.getStore().load({
            params:{
              order_id:orderId,
              start:1,
              limit:1
            }
          })

          Compass.ErpApp.Organizer.Layout.setActiveCenterItem('orders_layout', false);
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
    listeners:{
      activate:function(grid){
        var contactsLayout = grid.findParentByType('contactslayout');
        if(!Compass.ErpApp.Utility.isBlank(contactsLayout.partyId)){
          var store = grid.getStore();
          store.proxy.extraParams.party_id = contactsLayout.partyId;
          store.load({
            params:{
              start:0,
              limit:10
            }
          })
        }
      }
    }

});