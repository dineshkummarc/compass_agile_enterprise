$USE_SOLR_FOR_CONTENT = true
require 'sunspot_rails'

#add the observers path to load_paths
ActiveSupport::Dependencies.load_paths << RAILS_ROOT + "#{File.dirname(__FILE__)}/app/observers"
ActiveRecord::Base.observers << :contact_observer
#ActiveRecord::Base.observers << :solr_email_address_observer
ActiveRecord::Base.observers << :individual_observer
ActiveRecord::Base.observers << :organization_observer
ActiveRecord::Base.observers << :party_observer
ActiveRecord::Base.observers << :postal_address_observer

#remove this plugin for the load once paths
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

#if model exists in app/model this plugins model needs reloaded every request
#this runs only once when in production mode
config.to_prepare do
  RAILS_DEFAULT_LOGGER.debug("** reloading #{self.name} plugin") if RAILS_DEFAULT_LOGGER
  self.reload
end