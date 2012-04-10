#require all ActionView helper files
Dir.entries(File.join(File.dirname(__FILE__),"helpers")).delete_if{|name| name =~ /^\./}.each do |file|
  require "erp_app/extensions/railties/action_view/helpers/#{file}"
end

ActionView::Base.class_eval do
  include ErpApp::Extensions::Railties::ActionView::Helpers::IncludeHelper
  include ErpApp::Extensions::Railties::ActionView::Helpers::TagHelper
  include ErpApp::Extensions::Railties::ActionView::Helpers::ExtjsHelper
  include ErpApp::Extensions::Railties::ActionView::Helpers::ActiveExtHelper
  
end
