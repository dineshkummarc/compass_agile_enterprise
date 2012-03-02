ErpOrders::Engine.routes.draw do
  #Desktop Applications
  #
  #order_manager
  match '/erp_app/desktop/order_manager(/:action(/:id))' => 'erp_app/desktop/order_manager/base'


  #Organizer Applications
  #
  #order_management
  match '/erp_app/organizer/order_management(/:action(/:id))' => 'erp_app/organizer/order_management/base'
end


