module ErpFinancialAccounting
  class Engine < Rails::Engine
    isolate_namespace ErpFinancialAccounting
    
    #set engine to scope
  	engine = self
  	config.to_prepare do 
  		#load extensions for engine
  		engine.load_extensions
  	end
  end
end
