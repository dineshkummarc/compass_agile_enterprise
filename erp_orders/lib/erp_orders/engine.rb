module ErpOrders
  class Engine < Rails::Engine
    isolate_namespace ErpOrders
    
    initializer "erp_orders_assets.merge_public" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end
	  
	  ActiveSupport.on_load(:active_record) do
      include ErpOrders::Extensions::ActiveRecord::ActsAsOrderTxn
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
