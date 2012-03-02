require 'will_paginate'

module ErpApp
  class Engine < Rails::Engine
    isolate_namespace ErpApp

    config.erp_app = ErpApp::Config

	  initializer "erp_app_assets.merge_public" do |app|
      app.middleware.insert_before Rack::Lock, ::ActionDispatch::Static, "#{root}/public"
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

    engine = self
  	config.to_prepare do 
      ErpBaseErpSvcs.register_compass_ae_engine(engine)
      ::ErpApp::Widgets::Loader.load_root_widgets

      #will_paginate patch
      require 'erp_app/extensions/will_paginate_patch'
  	end
  end
end
