ActionController::Routing::Routes.draw do |map|
  #Desktop Applications

  #product_manager
  map.connect '/erp_app/desktop/product_manager/:action/:id', :controller => 'erp_app/desktop/product_manager/base'
end


