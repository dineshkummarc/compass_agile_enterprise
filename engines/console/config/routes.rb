
ActionController::Routing::Routes.draw do |map|
  
  

  
  map.connect '/console/:action.:format', :controller => 'erp_app/desktop/console/base'

   
end


