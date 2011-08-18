
ErpApp::Engine.routes.draw do
  
  ##########################
  #ErpApp general routes
  ##########################
  match '/application/:action' => "application"
  match '/login(/:action)' => "login"
  match '/public/:action' => "public"

  #############################
  #Shared Application Routes
  #############################
  match '/shared/notes/:action(/:party_id)' => "shared/notes"

  #############################
  #Organizer Application Routes
  #############################
  match '/organizer(/:action)' => "organizer/base"
  
  #crm
  match '/organizer/crm(/:action(/:id))' => "organizer/crm/base"

  ############################
  #Desktop Application Routes
  ############################
  match '/desktop' => "desktop/base#index"
  match '/desktop/login' => "desktop/login#index"

  #Desktop Applications

  #tenancy
  #match '/desktop/tenancy/:action' => "desktop/tenancy/base#index"

  #scaffold
  match '/desktop/scaffold/role/:action' => "desktop/scaffold/role"
  match '/desktop/scaffold/:action' => "desktop/scaffold/base"
  
  #user_management
  match '/desktop/user_management/users(/:action(/:id))' => "desktop/user_management/base"
  match '/desktop/user_management/role_management/:action' => "desktop/user_management/role_management"
  match '/desktop/user_management/application_management/:action' => "desktop/user_management/application_management"

  #system_management
  match '/desktop/system_management/:action' => "desktop/system_management/base#index"
  match '/desktop/system_management/application_role_management/:action' => "desktop/system_management/application_role_management"

  #control_panel
  match '/desktop/control_panel/application_management/:action(/:id)' => "desktop/control_panel/application_management"
  match '/desktop/control_panel/desktop_management/:action' => "desktop/control_panel/desktop_management"
  match '/desktop/control_panel/profile_management/:action' => "desktop/control_panel/profile_management"

  #file_manager
  match '/desktop/file_manager/base/:action' => "desktop/file_manager/base"
  match '/desktop/file_manager/download_file/:path' => "desktop/file_manager/base#download_file"

  #widget proxy
  match '/widgets/:widget_name/:widget_action/:uuid(/:id)' => "widget_proxy#index"
end


