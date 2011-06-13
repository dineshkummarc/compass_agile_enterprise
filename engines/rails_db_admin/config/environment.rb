Rails::Initializer.configure do |config|
  config.set_dependencies(:rails_db_admin, [:erp_app])
end
