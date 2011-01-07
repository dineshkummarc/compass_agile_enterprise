require 'ext_scaffold/ext_scaffold'
require 'acts_as_app_container'
require 'has_user_preferences'
require 'rails_ext/railties/action_view'

#add the observers path to load_paths
ActiveSupport::Dependencies.load_paths << RAILS_ROOT + "#{File.dirname(__FILE__)}/app/observers"

#remove this plugin for the load once paths
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

#if model exists in app/model this plugins model needs reloaded every request
#this runs only once when in production mode
config.to_prepare do
  #application loaders
  require 'erp_app/application_resource_loader/file_system_loader'
  require 'erp_app/application_resource_loader/desktop_application_loader'

  RAILS_DEFAULT_LOGGER.debug("** reloading #{self.name} plugin") if RAILS_DEFAULT_LOGGER
  self.reload
end

