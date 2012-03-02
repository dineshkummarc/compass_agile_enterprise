module CompassAeConsole
  class Engine < Rails::Engine
    isolate_namespace CompassAeConsole
    
    initializer "compass_console.merge_public" do |app|
      app.middleware.insert_before Rack::Lock, ::ActionDispatch::Static, "#{root}/public"
    end

    engine = self
    config.to_prepare do
      ErpBaseErpSvcs.register_compass_ae_engine(engine)
    end
    
  end
end
