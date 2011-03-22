ActionController::Routing::Routes.draw do |map|
  #Desktop Applications
  #railsdbadmin
  map.connect 'erp_app/desktop/rails_db_admin/base/:action/:table/:id', :controller => 'erp_app/desktop/rails_db_admin/base'
  map.connect 'erp_app/desktop/rails_db_admin/queries/:action/:table/:id', :controller => 'erp_app/desktop/rails_db_admin/queries'
end


