Rails.application.routes.draw do
  match '/download/:filename' => 'erp_app/public#download'
end

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
  #Mobile Application Routes
  #############################
  match '/mobile' => 'mobile/base#index'
  match '/mobile/login' => 'mobile/login#index'

  #Mobile Applications
  #user_management
  match '/mobile/user_management(/:action)' => "mobile/user_management/base"

  #############################
  #Organizer Application Routes
  #############################
  match '/organizer(/:action)' => "organizer/base"
  
  #crm
  match '/organizer/crm/relationship(/:action(/:id))' => "organizer/crm/relationship"
  match '/organizer/crm(/:action(/:id))' => "organizer/crm/base"

  ############################
  #Desktop Application Routes
  ############################
  match '/desktop' => "desktop/base#index"

  #Desktop Applications
  #scaffold
  match '/desktop/scaffold/:action' => "desktop/scaffold/base"
  match '/desktop/scaffold/role/:action(/:id)' => "desktop/scaffold/role#index"
  
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

  #configuration_management
  match '/erp_app/desktop/configuration_management(/:action)' => "erp_app/desktop/configuration_management/base"

  #widget proxy
  match '/widgets/:widget_name/:widget_action/:uuid(/:id)' => "widget_proxy#index", :as => :widget

  #shared
  match '/shared/configuration/(/:action(/:id(/:category_id)))' => "shared/configuration"
end


