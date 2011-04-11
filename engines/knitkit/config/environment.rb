Rails::Initializer.configure do |config|
  config.set_depenencies(:erp_app, [:erp_base_erp_svcs])

  config.gem 'paperclip', :version => '~> 2.3.8', :lib => 'paperclip', :source => "http://gems.github.com"
  config.gem 'rubyzip', :version => '~> 0.9.1', :lib => 'zip/zip'
  config.gem 'routing-filter', :version => '~> 0.2.3', :lib => 'routing-filter'
  config.gem 'nokogiri', :version => '~> 1.4.4', :lib => 'nokogiri'
end
