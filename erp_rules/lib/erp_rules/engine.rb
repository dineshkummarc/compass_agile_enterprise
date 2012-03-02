module ErpRules
  require "erp_base_erp_svcs"
  class Engine < Rails::Engine
    isolate_namespace ErpRules

    ActiveSupport.on_load :active_record do
      include ErpRules::Extensions::ActiveRecord::HasRuleContext
      include ErpRules::Extensions::ActiveRecord::ActsAsBusinessRule
      include ErpRules::Extensions::ActiveRecord::ActsAsSearchFilter
    end

    #TODO
    #this will be removed once rails 3.2 adds the ability to set the order of engine loading
    engine = self
    config.to_prepare do
      ErpBaseErpSvcs.register_compass_ae_engine(engine)
    end
  end
end
