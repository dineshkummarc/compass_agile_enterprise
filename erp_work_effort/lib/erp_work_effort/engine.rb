module ErpWorkEffort
  class Engine < Rails::Engine
    isolate_namespace ErpWorkEffort
    
    ActiveSupport.on_load(:active_record) do
      include ErpWorkEffort::Extensions::ActiveRecord::ActsAsProjectEffort
      include ErpWorkEffort::Extensions::ActiveRecord::ActsAsProjectRequirement
      include ErpWorkEffort::Extensions::ActiveRecord::ActsAsSupportEffort
      include ErpWorkEffort::Extensions::ActiveRecord::ActsAsSupportRequirement
    end

    #TODO
    #this will be removed once rails 3.2 adds the ability to set the order of engine loading
    engine = self
    config.to_prepare do
      ErpBaseErpSvcs.register_compass_ae_engine(engine)
    end
  end
end
