Rails::Initializer.configure do |config|
  
  config.reload_plugins = true if RAILS_ENV == 'development'
  config.set_dependencies(:erp_tech_services, [:erp_base_erp_svcs])
end
