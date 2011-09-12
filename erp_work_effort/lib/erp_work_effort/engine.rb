module ErpWorkEffort
  class Engine < Rails::Engine
    isolate_namespace ErpWorkEffort
    
    ActiveSupport.on_load(:active_record) do
      include ErpWorkEffort::Extensions::ActiveRecord::ActsAsProjectEffort
      include ErpWorkEffort::Extensions::ActiveRecord::ActsAsProjectRequirement
      include ErpWorkEffort::Extensions::ActiveRecord::ActsAsSupportEffort
      include ErpWorkEffort::Extensions::ActiveRecord::ActsAsSupportRequirement
    end
    
    #set engine to scope
  	engine = self
  	config.to_prepare do 
  		#load extensions for engine
  		engine.load_extensions
  	end
    
  end
end
