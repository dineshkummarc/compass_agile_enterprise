require 'erp_services/work_effort/acts_as_project_effort'
require 'erp_services/work_effort/acts_as_project_requirement'
require 'erp_services/work_effort/acts_as_support_effort'
require 'erp_services/work_effort/acts_as_support_requirement'

#add the observers path to load_paths
ActiveSupport::Dependencies.load_paths += [RAILS_ROOT + "#{File.dirname(__FILE__)}/app/observers"]

#remove this plugin for the load once paths
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

#if model exists in app/model this plugins model needs reloaded every request
#this runs only once when in production mode
config.to_prepare do
  RAILS_DEFAULT_LOGGER.debug("** reloading #{self.name} plugin") if RAILS_DEFAULT_LOGGER
  self.reload
end


