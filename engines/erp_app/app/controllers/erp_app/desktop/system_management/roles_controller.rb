class ErpApp::Desktop::SystemManagement::RolesController < ErpApp::Desktop::SystemManagement::BaseController
  active_ext :role do |options|
    options[:show_id] = true
    options[:ignore_associations] = false
    options[:show_timestamps] = true
    options[:only] = [:description, :internal_identifier]
    options
  end

end

 
