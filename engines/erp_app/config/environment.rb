Rails::Initializer.configure do |config|
  
  config.reload_plugins = true

  config.set_dependencies(:erp_app, [:erp_base_erp_svcs])
   
  config.gem 'json_pure', :version => '~> 1.5.1', :lib => 'json_pure', :source => "http://gems.github.com"
end
