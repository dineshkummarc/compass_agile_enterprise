class ErpApp::Desktop::Scaffold::WebsiteInquiryController < ErpApp::Desktop::Scaffold::BaseController
  active_ext WebsiteInquiry do |options|
    options[:inline_edit] = false
    options[:ignore_associations] = true
    options[:show_id] = true
    options[:show_timestamps] = true
    
    #additional options
    options[:use_ext_forms] = true
    #options[:only] = [ {:internal_identifier => {:required => true, :readonly => false}}]
    options
  end

end


