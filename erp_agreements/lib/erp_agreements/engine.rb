module ErpAgreements
  class Engine < Rails::Engine
    isolate_namespace ErpAgreements
    
    #set engine to scope
  	engine = self
  	config.to_prepare do 
  		#load extensions for engine
  		engine.load_extensions
  	end
  end
end
