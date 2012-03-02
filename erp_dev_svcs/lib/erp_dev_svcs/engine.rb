module ErpDevSvcs
  class Engine < Rails::Engine
    isolate_namespace ErpDevSvcs

    engine = self
    config.to_prepare do
      ErpBaseErpSvcs.register_compass_ae_engine(engine)
    end
  end
end
