ActionView::Base.class_eval do
  include ErpApp::Helpers::IncludeHelper
  include ErpApp::Helpers::TagHelper
  include ErpApp::Helpers::ExtjsHelper
  include ErpApp::Helpers::ActiveExtHelper
end
