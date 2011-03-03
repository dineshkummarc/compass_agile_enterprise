class ErpApp::Desktop::SystemManagement::RoleTypeController < ErpApp::Desktop::SystemManagement::BaseController
  active_ext RoleType do |options|
    options[:show_id] = true
    options[:show_timestamps] = true
    options
  end

end


