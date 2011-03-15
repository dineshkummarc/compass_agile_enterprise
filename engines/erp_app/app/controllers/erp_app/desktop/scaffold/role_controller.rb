class ErpApp::Desktop::Scaffold::RoleController < ErpApp::Desktop::Scaffold::BaseController
  active_ext Role do |options|
    options[:inline_edit] = false
    options[:ignore_associations] = true,
    options[:use_ext_forms] = true
    options[:show_id] = true
    options[:show_timestamps] = true
    options[:only] = [
      {:description => {:required => true, :readonly => false}},
      {:internal_identifier => {:required => true, :readonly => false}},
      {:external_identifier => {:required => false, :readonly => false}}
    ]
    options
  end

end


