Rails::Initializer.configure do |config|
  
  config.reload_plugins = true if RAILS_ENV == 'development'
  config.set_depenencies(:erp_tech_services, [:erp_base_erp_svcs])
end
