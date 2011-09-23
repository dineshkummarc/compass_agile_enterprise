require 'sunspot_rails'

module ErpSearch
  class Engine < Rails::Engine
    isolate_namespace ErpSearch
    
    #add observers
	  #this is ugly need a better way
	  observers = [:contact_observer, :email_address_observer, :organization_observer, :party_observer, :postal_address_observer]
	  (config.active_record.observers.nil?) ? config.active_record.observers = observers : config.active_record.observers += observers
	  
	  #set engine to scope
  	engine = self
  	config.to_prepare do 
  		#load extensions for engine
  		engine.load_extensions
  	end    
  end
end
