class ErpApp::Desktop::SystemManagement::PartyController < ErpApp::Desktop::SystemManagement::BaseController
  active_ext Party do |options|
    options[:inline_edit] = false
    options[:show_id] = true
    options[:show_timestamps] = true
    options
  end

end


