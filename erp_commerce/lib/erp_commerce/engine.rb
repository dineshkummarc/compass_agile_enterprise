module ErpCommerce
  class Engine < Rails::Engine
    isolate_namespace ErpCommerce

    config.erp_commerce = ErpCommerce::Config
    
    initializer "erp_commerce.merge_public" do |app|
      app.middleware.insert_before Rack::Lock, ::ActionDispatch::Static, "#{root}/public"
    end
	  
	  ActiveSupport.on_load(:active_record) do
      include ErpCommerce::Extensions::ActiveRecord::ActsAsFee
      include ErpCommerce::Extensions::ActiveRecord::ActsAsPriceable
    end

    #TODO
    #this will be removed once rails 3.2 adds the ability to set the order of engine loading
    engine = self
    config.to_prepare do
      ErpBaseErpSvcs.register_compass_ae_engine(engine)
      ::ErpApp::Widgets::Loader.load_compass_ae_widgets(engine)
    end
    
  end#Engine
end#ErpCommerce
