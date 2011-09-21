module RailsDbAdmin
  class Engine < Rails::Engine
    isolate_namespace RailsDbAdmin
    
    initializer "rails_db_admin.merge_public" do |app|
      app.middleware.insert_before ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
    end
  end
end
