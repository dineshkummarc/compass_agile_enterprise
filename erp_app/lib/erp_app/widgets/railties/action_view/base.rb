#require all ActionView helper files
Dir.entries(File.join(File.dirname(__FILE__),"helpers")).delete_if{|name| name =~ /^\./}.each do |file|
  require "erp_app/widgets/railties/action_view/helpers/#{file}"
end

ActionView::Base.class_eval do
  include ErpApp::Widgets::Railties::ActionView::Helpers::WidgetHelper
end
