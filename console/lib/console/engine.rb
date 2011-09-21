module Console
  class Engine < Rails::Engine
    isolate_namespace Console
    
    initializer "console.merge_public" do |app|
      app.middleware.insert_before ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
    end
    
  end
end
