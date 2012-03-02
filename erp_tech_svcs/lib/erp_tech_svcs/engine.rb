module ErpTechSvcs
  class Engine < Rails::Engine
    config.erp_tech_svcs = ErpTechSvcs::Config

    isolate_namespace ErpTechSvcs
	
	  ActiveSupport.on_load(:active_record) do
      include ErpTechSvcs::Extensions::ActiveRecord::HasRoles
      include ErpTechSvcs::Extensions::ActiveRecord::HasFileAssets
      include ErpTechSvcs::Extensions::ActiveRecord::HasCapabilities
    end

    engine = self
    config.to_prepare do
      ErpBaseErpSvcs.register_compass_ae_engine(engine)
    end
    
  end
end
