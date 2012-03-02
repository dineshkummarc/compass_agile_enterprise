require 'dynamic_attributes'

module ErpForms
  class Engine < Rails::Engine
    isolate_namespace ErpForms
    
	  initializer "erp_forms.merge_public" do |app|
      app.middleware.insert_before Rack::Lock, ::ActionDispatch::Static, "#{root}/public"
    end
	
    ActiveSupport.on_load(:active_record) do
      include ErpForms::Extensions::ActiveRecord::HasDynamicData
      include ErpForms::Extensions::ActiveRecord::HasDynamicForms
    end

    engine = self
    config.to_prepare do
      ErpBaseErpSvcs.register_compass_ae_engine(engine)

      #dynamic_attributes patch
      require "erp_forms/dynamic_attributes_patch"
  	end
	
  end
end
