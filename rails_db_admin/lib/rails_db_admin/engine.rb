module RailsDbAdmin
  class Engine < Rails::Engine
    isolate_namespace RailsDbAdmin
    
    initializer "erp_app_assets.merge_public" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end
  end
end
