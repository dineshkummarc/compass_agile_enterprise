require 'nokogiri'
require 'permalink_fu'
require 'acts-as-taggable-on'
require 'zip/zip'
require 'zip/zipfilesystem'

module Knitkit
  class Engine < Rails::Engine
    isolate_namespace Knitkit
	
	  initializer "knikit.merge_public" do |app|
      app.middleware.insert_before Rack::Lock, ::ActionDispatch::Static, "#{root}/public"
    end
	  
	  ActiveSupport.on_load(:active_record) do
      include Knitkit::Extensions::ActiveRecord::ActsAsCommentable
      include Knitkit::Extensions::ActiveRecord::ActsAsPublishable
      include Knitkit::Extensions::ActiveRecord::ThemeSupport::HasManyThemes
      extend Knitkit::Extensions::ActiveRecord::StiInstantiation::ActMacro
    end
    
    ActiveSupport.on_load(:action_controller) do
      include Knitkit::Extensions::ActionController::ThemeSupport::ActsAsThemedController
    end
    
    # Add widgets to load path
    config.autoload_paths << "#{root}/lib/erp_app/*"
    
    #set engine to scope
  	engine = self
  	config.to_prepare do 
  		#load extensions for engine
  		engine.load_extensions
  		#load widgets for engine
  		engine.load_widgets
  	end
    
  end
end
