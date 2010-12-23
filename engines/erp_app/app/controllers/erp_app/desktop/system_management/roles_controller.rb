class ErpApp::Desktop::SystemManagement::RolesController < ErpApp::Desktop::SystemManagement::BaseController
  ext_scaffold Role do |options|
    options[:show_id] = true
    options[:show_timestamps] = true
    options[:only] = [:description, :internal_identifier]
    options
  end

end

 
