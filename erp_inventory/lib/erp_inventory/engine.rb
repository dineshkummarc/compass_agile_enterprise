module ErpInventory
  class Engine < Rails::Engine
    isolate_namespace ErpInventory

    initializer "erp_inventory.merge_public" do |app|
      app.middleware.insert_before Rack::Lock, ::ActionDispatch::Static, "#{root}/public"
    end

    ActiveSupport.on_load(:active_record) do
      include ErpInventory::Extensions::ActiveRecord::ActsAsInventoryEntry
    end

    engine = self
    config.to_prepare do
      ErpBaseErpSvcs.register_compass_ae_engine(engine)
    end
  end
end
