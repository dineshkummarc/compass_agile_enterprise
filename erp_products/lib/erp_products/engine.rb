module ErpProducts
  class Engine < Rails::Engine
    isolate_namespace ErpProducts
	
	  initializer "erp_products.merge_public" do |app|
      app.middleware.insert_before ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
    end
	  
	  ActiveSupport.on_load(:active_record) do
      include ErpProducts::Extensions::ActiveRecord::ActsAsProductInstance
      include ErpProducts::Extensions::ActiveRecord::ActsAsProductOffer
	    include ErpProducts::Extensions::ActiveRecord::ActsAsProductType
    end
	
	  #set engine to scope
  	engine = self
  	config.to_prepare do 
  		#load extensions for engine
  		engine.load_extensions
  	end
  end
end
