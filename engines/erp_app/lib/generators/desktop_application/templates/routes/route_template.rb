ActionController::Routing::Routes.draw do |map|
  map.connect '/erp_app/desktop/<%=file_name %>/:action', :controller => 'erp_app/desktop/<%=file_name %>/base'
end
