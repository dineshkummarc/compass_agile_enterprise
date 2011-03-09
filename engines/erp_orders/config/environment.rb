Rails::Initializer.configure do |config|
  
  config.reload_plugins = true

  config.set_depenencies(:erp_orders, [:erp_base_erp_svcs, :erp_txns_and_accts, :erp_products, :erp_inventory])
end
