Rails::Initializer.configure do |config|
  config.set_dependencies(:erp_app, [:erp_orders])

  config.gem 'aasm', :version => '~> 2.2.0', :lib => 'aasm', :source => "http://gems.github.com"
end
