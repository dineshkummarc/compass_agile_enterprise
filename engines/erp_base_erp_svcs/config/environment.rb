Rails::Initializer.configure do |config|
  
  config.reload_plugins = true

  config.gem 'rake', :version => '~> 0.8.7', :lib => 'rake', :source => "http://gems.github.com"
  config.gem 'quick_magick', :version => '~> 0.8.0', :lib => 'quick_magick', :source => "http://gems.github.com"
  config.gem 'has_many_polymorphic', :version => '~> 0.0.2', :lib => 'has_many_polymorphic'
end
