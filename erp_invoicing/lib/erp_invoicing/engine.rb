module ErpInvoicing
  class Engine < Rails::Engine
    isolate_namespace ErpInvoicing

    initializer "erp_invoicing.merge_public" do |app|
      app.middleware.insert_before Rack::Lock, ::ActionDispatch::Static, "#{root}/public"
    end

    engine = self
    config.to_prepare do
      ErpBaseErpSvcs.register_compass_ae_engine(engine)
      ::ErpApp::Widgets::Loader.load_compass_ae_widgets(engine)
    end
  end
end
