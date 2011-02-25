Rails::Initializer.configure do |config|
  config.gem 'paperclip', :version => '~> 2.3.8', :lib => 'paperclip', :source => "http://gems.github.com"
  config.set_depenencies(:erp_app, [:erp_base_erp_svcs])
end
