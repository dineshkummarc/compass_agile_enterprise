require 'tenancy'

# remove plugin from load_once_paths
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

require 'compass_extensions'

#if model exists in app/model this plugins model needs reloaded every request
#this runs only once when in production mode
config.to_prepare do
  RAILS_DEFAULT_LOGGER.debug("** reloading #{self.name} plugin") if RAILS_DEFAULT_LOGGER
  self.reload
end

