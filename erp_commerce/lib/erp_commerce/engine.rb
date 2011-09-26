module ErpCommerce
  class Engine < Rails::Engine
    isolate_namespace ErpCommerce
    
    initializer "erp_commerce.merge_public" do |app|
      app.middleware.insert_before Rack::Lock, ::ActionDispatch::Static, "#{root}/public"
    end
	  
	  ActiveSupport.on_load(:active_record) do
      include ErpCommerce::Extensions::ActiveRecord::ActsAsFee
      include ErpCommerce::Extensions::ActiveRecord::ActsAsPriceable
    end
      
	  #set engine to scope
  	engine = self
  	config.to_prepare do 
  	  #load widgets that might live in root/app/widgets
  	  engine.load_widgets
  		#load extensions for engine
  		engine.load_extensions
  	end
  end
end
