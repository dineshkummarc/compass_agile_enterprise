#remove this plugin for the load once paths
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

require 'core_ext'
require 'rails_ext'
require 'theme_support'

#if model exists in app/model this plugins model needs reloaded every request
#this runs only once when in production mode
config.to_prepare do
  Section.register_type 'Blog'

  RAILS_DEFAULT_LOGGER.debug("** reloading #{self.name} plugin") if RAILS_DEFAULT_LOGGER
  self.reload
end

