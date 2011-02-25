require 'active_ext/active_ext'
require 'acts_as_app_container'
require 'has_user_preferences'
require 'rails_ext/railties/action_view'
require 'erp_app/application_resource_loader/file_system_loader'

#add the observers path to load_paths
ActiveSupport::Dependencies.load_paths << RAILS_ROOT + "#{File.dirname(__FILE__)}/app/observers"

#remove this plugin for the load once paths
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

#if model exists in app/model this plugins model needs reloaded every request
#this runs only once when in production mode
config.to_prepare do
  #check if this is windows.  PermalinkFu has issues in windows with iconv
  if RUBY_PLATFORM =~ /(:?mswin|mingw)/
    PermalinkFu.translation_to = nil
    PermalinkFu.translation_from = nil
  end
  
  RAILS_DEFAULT_LOGGER.debug("** reloading #{self.name} plugin") if RAILS_DEFAULT_LOGGER
  self.reload
end

