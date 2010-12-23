ActionController::Routing::Routes.draw do |map|
  map.connect '/erp_app/organizer/<%=file_name %>/:action', :controller => 'erp_app/organizer/<%=file_name %>/base'
end
