# - keep track of plugins in Rails.plugins
# - allow engines to ship their own vendor/plugins
# - add observers to plugin.app_paths
# - add an alias to register_[asset]_expansion to plugins

Rails::Configuration.class_eval do
  def default_plugin_loader
    Rails::Plugin::RegisteringLoader
  end
  
  def default_plugin_locators
    locators = []
    locators << Rails::Plugin::GemLocator if defined? Gem
    locators << Rails::Plugin::NestedFileSystemLocator
  end
end

Rails::Plugin.class_eval do
 
  #forces rails to reload models in this plugin
  #params
  #plugin_path (string) optional specify path if it is a nested plugin
  #lib_files_to_reload (array) optional specify acts_as mixins to reload
  def reload(plugin_path=nil)
    path = Rails.configuration.plugin_paths[0]

    app_models_path = "#{RAILS_ROOT}/app/models/"
    plugin_path = plugin_path || "#{path}/#{self.name}"
    plugin_models_path = "#{plugin_path}/app/models/"
    plugin_extensions_path = "#{plugin_models_path}extensions/"
    tables = ActiveRecord::Base.connection.tables

    begin
      #get all files from this plugins app/model directory
      model_extension_files = Dir.entries(plugin_extensions_path).map{|directory| directory}
      #remove any .svn or .data files
      model_extension_files.delete_if{|name| name =~ /^\./}

      #Must use eval to run each extension so rails picks up the extension
      model_extension_files.each do |filename|
        #check if table exists
        content = File.open(plugin_extensions_path + filename) { |f| f.read }
        class_name = filename[0..-4]
        if tables.include?(class_name.tableize)
          eval(IO.read(plugin_extensions_path + filename), binding, plugin_extensions_path + filename)
        end
      end
    end if File.directory? plugin_extensions_path

    begin
      #get all files from this plugins app/model directory
      model_files = Dir.entries(plugin_models_path).map{|directory| directory}
      #remove any .svn or .data files
      model_files.delete_if{|name| name =~ /^\./}
      #exclude the extension directory
      model_files.delete_if{|name| name == "extensions"}

      model_files.each do |filename|
        
        class_name = filename[0..-4]
        klass = class_name.camelize

        #if there is a model in {rails_root}/app/models it needs to be reloaded.
        #used to turn a class declaration into a class eval
        if FileTest.exists?(app_models_path + filename)
          content = File.open(plugin_models_path + filename) { |f| f.read }
          #make sure this class extends ActiveRecord::Base
          #we only want to do this for ActiveRecord models
          if content.include? '< ActiveRecord::Base'
            if tables.include?(class_name.tableize)
              content.gsub!("class #{klass} < ActiveRecord::Base", "#{klass}.class_eval do")
              eval(content, binding)
            end
          end
        end
      end
    end if File.directory? plugin_models_path
  end

end

module Rails
  class << self
    def plugins
      @@plugins ||= ActiveSupport::OrderedHash.new
    end
  
    def plugin?(name)
      plugins.keys.include?(name.to_sym)
    end
  end

  class Plugin
    class RegisteringLoader < Rails::Plugin::Loader # ummm, what's a better name?
      def register_plugin_as_loaded(plugin)
        Rails.plugins[plugin.name.to_sym] = plugin
        super
      end
    end
  
    def app_paths
      ['models', 'helpers', 'observers'].map { |path| File.join(directory, 'app', path) } << controller_path << metal_path
    end
  
    def register_javascript_expansion(*args)
      ActionView::Helpers::AssetTagHelper.register_javascript_expansion *args
    end
  
    def register_stylesheet_expansion(*args)
      ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion *args
    end
    
    class NestedFileSystemLocator < FileSystemLocator
      def locate_plugins_under(base_path)
        plugins = super
        Dir["{#{plugins.map(&:directory).join(',')}}/vendor/plugins"].each do |path|
          plugins.concat super(path)
        end unless plugins.empty?
        plugins
      end
    end
  end
end
