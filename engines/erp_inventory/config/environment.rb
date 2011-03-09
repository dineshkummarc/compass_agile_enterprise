Rails::Initializer.configure do |config|
  
  config.reload_plugins = true

  config.set_depenencies(:erp_inventory, [:erp_base_erp_svcs, :erp_products])
end
