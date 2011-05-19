
ActionController::Routing::Routes.draw do |map|
  
  ##########################
  #ErpApp general routes
  ##########################
  map.desktop_logout '/erp_app/logout', :controller => 'erp_app/application', :action => 'destroy'
  map.connect '/erp_app/public/:action', :controller => 'erp_app/public'

  #############################
  #Organizer Application Routes
  #############################
  map.organizer_login '/erp_app/organizer/login', :controller => 'erp_app/organizer/login', :action => 'index'
  map.connect '/erp_app/organizer', :controller => 'erp_app/organizer/base', :action => 'index'

  #admin_center
  map.connect '/erp_app/organizer/admin_center/:action', :controller => 'erp_app/organizer/admin_center/base'
  
  #crm
  map.connect '/erp_app/organizer/crm/:action/:id', :controller => 'erp_app/organizer/crm/base'

  ############################
  #Desktop Application Routes
  ############################
  map.desktop '/erp_app/desktop', :controller => 'erp_app/desktop/base', :action => 'index'
  map.desktop_login '/erp_app/desktop/login', :controller => 'erp_app/desktop/login', :action => 'index'

  #Desktop Applications

  #tenancy
  map.connect '/erp_app/desktop/tenancy/:action', :controller => 'erp_app/desktop/tenancy/base'

  #tenancy
  map.connect '/erp_app/desktop/tenancy/:action', :controller => 'erp_app/desktop/tenancy/base'

  #scaffold
  map.connect '/erp_app/desktop/scaffold/role/:action', :controller => 'erp_app/desktop/scaffold/role'
  map.connect '/erp_app/desktop/scaffold/:action', :controller => 'erp_app/desktop/scaffold/base'

  #knitkit
  map.connect '/erp_app/desktop/knitkit/:action', :controller => 'erp_app/desktop/knitkit/base'

  #user_management
  map.connect '/erp_app/desktop/user_management/users/:action/:id' , :controller => 'erp_app/desktop/user_management/base'
  map.connect '/erp_app/desktop/user_management/role_management/:action/' , :controller => 'erp_app/desktop/user_management/role_management'
  map.connect '/erp_app/desktop/user_management/application_management/:action/' , :controller => 'erp_app/desktop/user_management/application_management'

  #system_management
  map.connect '/erp_app/desktop/system_management/:action', :controller => 'erp_app/desktop/system_management/base'
  map.connect '/erp_app/desktop/system_management/application_role_management/:action', :controller => 'erp_app/desktop/system_management/application_role_management'

  #control_panel
  map.connect '/erp_app/desktop/control_panel/application_management/:action/:id', :controller => 'erp_app/desktop/control_panel/application_management'
  map.connect '/erp_app/desktop/control_panel/desktop_management/:action', :controller => 'erp_app/desktop/control_panel/desktop_management'
  map.connect '/erp_app/desktop/control_panel/profile_management/:action/' , :controller => 'erp_app/desktop/control_panel/profile_management'

  #file_manager
  map.connect '/erp_app/desktop/file_manager/:action', :controller => 'erp_app/desktop/file_manager/base'
  map.connect '/erp_app/desktop/file_manager/download_file/:path', :controller => 'erp_app/desktop/file_manager/base', :action => 'download_file'

  #widget proxy
  map.connect '/widgets/:widget_name/:widget_action', :controller => 'erp_app/widget_proxy'
end


