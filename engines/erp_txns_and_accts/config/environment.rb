Rails::Initializer.configure do |config|
  
  config.reload_plugins = true

  config.set_depenencies(:erp_txns_and_accts, [:erp_base_erp_svcs, :erp_agreements])
end
