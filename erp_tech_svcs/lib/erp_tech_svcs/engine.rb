module ErpTechSvcs
  class Engine < Rails::Engine
    isolate_namespace ErpTechSvcs
	
	  ActiveSupport.on_load(:active_record) do
      include ErpTechSvcs::Extensions::ActiveRecord::ActsAsSecured
      include ErpTechSvcs::Extensions::ActiveRecord::HasFileAssets
    end
    
    #set engine to scope
  	engine = self
  	config.to_prepare do 
  		#load extensions for engine
  		engine.load_extensions
  	end
  	
  end
end
