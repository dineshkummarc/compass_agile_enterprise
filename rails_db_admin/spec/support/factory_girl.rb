require 'factory_girl'
Dir[File.join(ENGINE_RAILS_ROOT, "../erp_app/spec/factories/*")].each do |factory|
  require factory
end
FactoryGirl.find_definitions
