ActionController::Routing::Routes.draw do |map|
  #load up all routes for applications in all plugins
  Rails.plugins.each do |name, plugin|
    if File.exist?(File.join(plugin.directory,'config'))
      Dir.glob(File.join(plugin.directory,'config','*_app_routes.rb')).each do |file|
        eval(File.open(file) { |f| f.read })
      end
    end
  end

  ##########################
  #erp app routes
  ##########################
  map.desktop_logout '/erp_app/logout', :controller => 'erp_app/application', :action => 'destroy'

  ##########################
  #Organizer Application Routes
  ##########################
  map.organizer_login '/erp_app/organizer/login', :controller => 'erp_app/organizer/login', :action => 'index'
  map.connect '/erp_app/organizer', :controller => 'erp_app/organizer/base', :action => 'index'

  map.connect '/erp_app/test', :controller => 'erp_app/organizer/base', :action => 'test'
  

  ##########################
  #Organizer Applications
  ##########################
  map.connect '/erp_app/organizer/crm/:action/:id', :controller => 'erp_app/organizer/crm/base'

  #Desktop Application Routes
  map.desktop '/erp_app/desktop', :controller => 'erp_app/desktop/base', :action => 'index'
  map.desktop_login '/erp_app/desktop/login', :controller => 'erp_app/desktop/login', :action => 'index'

  ##########################
  #Desktop Applications
  ##########################
  #user management
  map.connect '/erp_app/desktop/user_management/users/:action/:id' , :controller => 'erp_app/desktop/user_management/base'
  map.connect '/erp_app/desktop/user_management/role_management/:action/' , :controller => 'erp_app/desktop/user_management/role_management'
  map.connect '/erp_app/desktop/user_management/application_management/:action/' , :controller => 'erp_app/desktop/user_management/application_management'

  #system management
  map.connect '/erp_app/desktop/system_management/:action', :controller => 'erp_app/desktop/system_management/base'
  map.connect '/erp_app/desktop/system_management/roles/:action', :controller => 'erp_app/desktop/system_management/roles'
  map.connect '/erp_app/desktop/system_management/application_role_management/:action', :controller => 'erp_app/desktop/system_management/application_role_management'

  #control panel
  map.connect '/erp_app/desktop/control_panel/application_management/:action/:id', :controller => 'erp_app/desktop/control_panel/application_management'
  map.connect '/erp_app/desktop/control_panel/desktop_management/:action', :controller => 'erp_app/desktop/control_panel/desktop_management'

  
end


