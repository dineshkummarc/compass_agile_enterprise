module ErpProducts
  class Engine < Rails::Engine
    isolate_namespace ErpProducts
	
	  initializer "erp_products.merge_public" do |app|
      app.middleware.insert_before Rack::Lock, ::ActionDispatch::Static, "#{root}/public"
    end
	  
	  ActiveSupport.on_load(:active_record) do
      include ErpProducts::Extensions::ActiveRecord::ActsAsProductInstance
      include ErpProducts::Extensions::ActiveRecord::ActsAsProductOffer
	    include ErpProducts::Extensions::ActiveRecord::ActsAsProductType
    end

    #TODO
    #this will be removed once rails 3.2 adds the ability to set the order of engine loading
    engine = self
    config.to_prepare do
      ErpBaseErpSvcs.register_compass_ae_engine(engine)
    end
  end
end
