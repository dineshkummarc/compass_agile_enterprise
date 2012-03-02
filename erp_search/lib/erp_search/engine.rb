require 'sunspot_rails'

module ErpSearch
  class Engine < Rails::Engine
    isolate_namespace ErpSearch
    
    #add observers
	  #this is ugly need a better way
	  observers = [:party_observer, :contact_observer]
	  (config.active_record.observers.nil?) ? config.active_record.observers = observers : config.active_record.observers += observers

    #TODO
    #this will be removed once rails 3.2 adds the ability to set the order of engine loading
    engine = self
    config.to_prepare do
      ErpBaseErpSvcs.register_compass_ae_engine(engine)
    end
  end
end
