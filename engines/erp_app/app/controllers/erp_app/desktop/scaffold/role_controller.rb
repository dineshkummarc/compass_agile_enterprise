class ErpApp::Desktop::Scaffold::RoleController < ErpApp::Desktop::Scaffold::BaseController
  active_ext Role do |options|
    options[:inline_edit] = true
    options[:show_id] = true
    options[:show_timestamps] = true
    options
  end

end


