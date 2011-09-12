module ErpInventory
  class Engine < Rails::Engine
    isolate_namespace ErpInventory
    
    ActiveSupport.on_load(:active_record) do
      include ErpInventory::Extensions::ActiveRecord::ActsAsInventoryEntry
    end
      
	  #set engine to scope
  	engine = self
  	config.to_prepare do 
  		#load extensions for engine
  		engine.load_extensions
  	end
  end
end
