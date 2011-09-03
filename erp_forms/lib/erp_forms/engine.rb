require 'dynamic_attributes'

module ErpForms
  class Engine < Rails::Engine
    isolate_namespace ErpForms
    
	initializer "erp_app_assets.merge_public" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end
	
    ActiveSupport.on_load(:active_record) do
      include ErpForms::Extensions::ActiveRecord::HasDynamicData
      include ErpForms::Extensions::ActiveRecord::HasDynamicForms
    end
	
	#set engine to scope
  	engine = self
  	config.to_prepare do 
      #load extensions for engine
  	  engine.load_extensions
  	  #load widgets for engine
  	  engine.load_widgets
  	end
	
  end
end
