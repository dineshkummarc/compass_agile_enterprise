module ErpCommunicationEvents
  class Engine < Rails::Engine
    isolate_namespace ErpCommunicationEvents
    
    #add observers
	  #this is ugly need a better way
	  (config.active_record.observers.nil?) ? config.active_record.observers = [:communication_event_observer] : config.active_record.observers << :communication_event_observer
	  config.active_record.observers << :email_address_change_event_observer
	  config.active_record.observers << :phone_number_change_event_observer
	  config.active_record.observers << :phone_number_change_event_observer

    #TODO
    #this will be removed once rails 3.2 adds the ability to set the order of engine loading
    engine = self
    config.to_prepare do
      ErpBaseErpSvcs.register_compass_ae_engine(engine)
    end
  end
end
