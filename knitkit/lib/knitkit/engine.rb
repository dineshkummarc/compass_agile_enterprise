require 'nokogiri'
require 'permalink_fu'
require 'acts-as-taggable-on'
require 'zip/zip'
require 'zip/zipfilesystem'

module Knitkit
  class Engine < Rails::Engine
    isolate_namespace Knitkit

    config.knitkit = Knitkit::Config
	
	  initializer "knikit.merge_public" do |app|
      app.middleware.insert_before Rack::Lock, ::ActionDispatch::Static, "#{root}/public"
    end

	  ActiveSupport.on_load(:active_record) do
      include Knitkit::Extensions::ActiveRecord::ActsAsCommentable
      include Knitkit::Extensions::ActiveRecord::ActsAsPublishable
      include Knitkit::Extensions::ActiveRecord::ThemeSupport::HasManyThemes
      include Knitkit::Extensions::ActiveRecord::HasRelationalDynamicAttributes
    end

    ActiveSupport.on_load(:action_controller) do
      include Knitkit::Extensions::ActionController::ThemeSupport::ActsAsThemedController
    end

    engine = self
    config.to_prepare do
      ErpBaseErpSvcs.register_compass_ae_engine(engine)
      ::ErpApp::Widgets::Loader.load_compass_ae_widgets(engine)
    end
    
  end#Engine
end#Knitkit