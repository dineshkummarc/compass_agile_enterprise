require "erp_base_erp_svcs/version"
require "erp_base_erp_svcs/extensions"
require "erp_base_erp_svcs/ar_fixtures"
require "erp_base_erp_svcs/config"
require "erp_base_erp_svcs/engine"
require "erp_base_erp_svcs/non_escape_json_string"

module ErpBaseErpSvcs
  class << self
    def mount_compass_ae_engines(routes)
      Rails.application.config.erp_base_erp_svcs.compass_ae_engines.each do |engine|
        routes.mount engine => "/#{engine.name.split("::").first.underscore}"
      end
    end

    def register_compass_ae_engine(engine)
      Rails.application.config.erp_base_erp_svcs.compass_ae_engines << engine
      load_compass_ae_extensions(engine)
      load_root_compass_ae_framework_extensions()
    end

    #forces rails to reload model extensions and framework extensions
    def load_compass_ae_extensions(engine)
      load_compass_ae_model_extensions(engine)
      load_compass_ae_framework_extensions(engine)
    end

    def load_compass_ae_model_extensions(engine)
      root_models_path = "#{Rails.root}/app/models/"
      engine_path = engine.root.to_s
      engine_models_path = "#{engine_path}/app/models/"
      engine_extensions_path = "#{engine_models_path}extensions/"

      begin
        #get all files from this engines app/model directory
        model_extension_files = Dir.entries(engine_extensions_path).map{|directory| directory}
        #remove any .svn or .data files
        model_extension_files.delete_if{|name| name =~ /^\./}

        #Must use eval to run each extension so rails picks up the extension
        model_extension_files.each do |filename|
          #check if table exists
          content = File.open(engine_extensions_path + filename) { |f| f.read }
          class_name = filename[0..-4]
          #if tables.include?(class_name.tableize)
          eval(IO.read(engine_extensions_path + filename), binding, engine_extensions_path + filename)
          #end
        end
      end if File.directory? engine_extensions_path

      begin
        #get all files from this engines app/model directory
        model_files = Dir.entries(engine_models_path).map{|directory| directory}
        #remove any .svn or .data files
        model_files.delete_if{|name| name =~ /^\./}
        #exclude the extension directory
        model_files.delete_if{|name| name == "extensions"}

        model_files.each do |filename|

          class_name = filename[0..-4]
          klass = class_name.camelize

          #if there is a model in {rails_root}/app/models, it's not going to load our engine models.
          #load the engine model here and change it to a class_eval
          if File.exists?(root_models_path + filename)
            content = File.open(engine_models_path + filename) { |f| f.read }
            #make sure this class extends ActiveRecord::Base
            #we only want to do this for ActiveRecord models
            if content.include? '< ActiveRecord::Base'
              #if tables.include?(class_name.tableize)
              content.gsub!("class #{klass} < ActiveRecord::Base", "#{klass}.class_eval do")
              eval(content, binding)
              #end
            end
          end
        end
      end if File.directory? engine_models_path
      
    end

    def load_compass_ae_framework_extensions(engine)
      if File.directory? File.join(engine.root,"lib",engine.railtie_name,"extensions/compass_ae")
        Dir.glob(File.join(engine.root,"lib",engine.railtie_name,"extensions/compass_ae/**/*.rb")).each do |file|
          load file
        end
      end
    end

    def load_root_compass_ae_framework_extensions
      Dir.glob(File.join(Rails.root,"lib/extensions/compass_ae/**/*.rb")).each do |file|
        load file
      end
    end
    
  end
end


