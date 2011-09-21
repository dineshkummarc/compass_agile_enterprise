require 'will_paginate'

module ErpApp
  class Engine < Rails::Engine
    isolate_namespace ErpApp
    
	  initializer "erp_app_assets.merge_public" do |app|
      app.middleware.insert_before ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
    end
    
	  ActiveSupport.on_load(:active_record) do
      include ErpApp::Extensions::ActiveRecord::HasUserPreferences
      include ErpApp::Extensions::ActiveRecord::ActsAsAppContainer
    end
	  
	  ActiveSupport.on_load(:action_controller) do
      include ActiveExt
    end
      
	  #add observers
	  #this is ugly need a better way
	  (config.active_record.observers.nil?) ? config.active_record.observers = [:user_app_container_observer] : config.active_record.observers << :user_app_container_observer
		  
	  #set engine to scope
  	engine = self
  	config.to_prepare do 
  	  #load widgets that might live in root/app/widgets
  	  engine.load_root_widgets
  		#load extensions for engine
  		engine.load_extensions
  	end
  end
end
