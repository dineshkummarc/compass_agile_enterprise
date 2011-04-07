ActionController::Routing::Routes.draw do |map|
  #Desktop Applications
  #tenancy
  map.connect 'erp_app/desktop/tenacy/base/:action', :controller => 'erp_app/desktop/tenacy/base'
  map.connect 'tenancy/redirect/:route', :controller => 'tenancy/redirect'
end


