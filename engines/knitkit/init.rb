#remove this plugin for the load once paths
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

#add the observers path to load_paths
ActiveSupport::Dependencies.load_paths << "#{File.dirname(__FILE__)}/app/observers"

# load widget models
ErpApp::Widgets::Base.installed_widgets.each do |widget|
  ActiveSupport::Dependencies.load_paths << "#{File.dirname(__FILE__)}/lib/erp_app/widgets/#{widget}/models"
end

require 'core_ext'
require 'theme_support'
require 'knitkit'

ActiveRecord::Base.observers << :knitkit_user_observer

#if model exists in app/model this plugins model needs reloaded every request
#this runs only once when in production mode
config.to_prepare do
  WebsiteSection.register_type 'Blog'

  RAILS_DEFAULT_LOGGER.debug("** reloading #{self.name} plugin") if RAILS_DEFAULT_LOGGER
  self.reload
end

