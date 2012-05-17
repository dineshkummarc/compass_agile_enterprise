module CompassDrive
  class Engine < Rails::Engine
    isolate_namespace CompassDrive

    config.compass_drive = CompassDrive::Config

    initializer "compass_drive_assets.merge_public" do |app|
      app.middleware.insert_before Rack::Lock, ::ActionDispatch::Static, "#{root}/public"
    end

    #TODO
    #this will be removed once rails 3.2 adds the ability to set the order of engine loading
    engine = self
    config.to_prepare do
      ErpBaseErpSvcs.register_compass_ae_engine(engine)
    end
  end
end
