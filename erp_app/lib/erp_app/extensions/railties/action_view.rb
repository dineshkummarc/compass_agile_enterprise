ActionView::Base.class_eval do
  include ErpApp::IncludeHelper
  include ErpApp::TagHelper
  include ErpApp::ExtjsHelper
  include ErpApp::ActiveExtHelper
  
end
