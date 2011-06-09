require 'dynamic_attributes'
require 'has_dynamic_forms'
require 'has_dynamic_data'
require 'erp_forms/railties/action_view'

ActiveSupport::Dependencies.load_paths << "#{File.dirname(__FILE__)}/app/observers"

#remove this plugin for the load once paths
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

#if model exists in app/model this plugins model needs reloaded every request
#this runs only once when in production mode
config.to_prepare do
  RAILS_DEFAULT_LOGGER.debug("** reloading #{self.name} plugin") if RAILS_DEFAULT_LOGGER
  self.reload
end