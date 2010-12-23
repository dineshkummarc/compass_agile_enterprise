ActionController::Routing::Routes.draw do |map|
  map.connect '/rails_db_admin/base/:action/:table/:id', :controller => 'rails_db_admin/base'
  map.connect '/rails_db_admin/queries/:action/:table/:id', :controller => 'rails_db_admin/queries'

  map.rails_db_admin_login '/rails_db_admin/login', :controller => 'rails_db_admin/login', :action => 'index'
end


