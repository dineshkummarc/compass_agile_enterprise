require 'dynamic_attributes'

module ErpForms
  class Engine < Rails::Engine
    isolate_namespace ErpForms
    
    ActiveSupport.on_load(:active_record) do
      include ErpForms::Extensions::ActiveRecord::HasDynamicData
      include ErpForms::Extensions::ActiveRecord::HasDynamicForms
    end
  end
end
