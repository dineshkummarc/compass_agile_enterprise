class ErpApp::Desktop::Scaffold::AgreementController < ErpApp::Desktop::Scaffold::BaseController
  active_ext Agreement do |options|
    options[:inline_edit] = true
    options[:ignore_associations] = true
    options[:show_id] = true
    options[:show_timestamps] = true
    
    #additional options
    #options[:use_ext_forms] = false
    #options[:only] = [ {:internal_identifier => {:required => true, :readonly => false}}]
    options
  end

end


