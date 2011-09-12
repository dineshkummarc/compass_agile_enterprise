ActionController::Routing::Routes.draw do |map|
  #Desktop Applications
  #
  #order_manager
  map.connect '/erp_app/desktop/order_manager/:action/:id', :controller => 'erp_app/desktop/order_manager/base'


  #Organizer Applications
  #
  #order_management
  map.connect '/erp_app/organizer/order_management/:action/:id', :controller => 'erp_app/organizer/order_management/base'
end


