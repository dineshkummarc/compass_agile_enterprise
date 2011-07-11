require "#{File.dirname(__FILE__)}/lib/rails_ext/railties/plugin"
require "#{File.dirname(__FILE__)}/lib/core_ext/array"
require "#{File.dirname(__FILE__)}/lib/core_ext/numbers"
require "#{File.dirname(__FILE__)}/lib/core_ext/hash"

Rails::Configuration.class_eval do
  @@dependencies = {}

  def set_dependencies(plugin, dependencies)
    @@dependencies[plugin] = dependencies
  end
  
  def default_plugin_paths
    paths = ["#{root_path}/vendor/plugins"]
    paths
  end

  #######################################################################################
  #Russell Holmes
  #08/02/2010
  #
  #Allows for more control over order of plugin loading
  #Loads nested plugins
  #Checks plugin dependencies
  #Disables selected plugins
  #######################################################################################
  def add_plugin(plugin)

    if self.plugins.nil? 
      self.plugins = []
    end
    if plugin.to_sym == :all
      add_all_non_added_plugins
    else
      unless plugin_exists?(plugin)
        dependencies = @@dependencies[plugin]
        if dependencies.nil?
          add_plugin_and_nested_plugins(plugin)
        else
          if dependencies_exist?(dependencies)
            add_plugin_and_nested_plugins(plugin)
          else
            puts "!Warning missing one or more dependencies [#{dependencies.join(',')}] for plugin #{plugin}"
          end
        end
      else
        puts "!Warning plugin already added #{plugin}"
      end
    end
  end

  def disable_plugins(plugins)
    plugins.each do |plugin|
      disable_plugin(plugin)
    end
  end

  def disable_plugin(plugin)
    if plugin_exists?(plugin)
      self.plugins.delete(plugin)
    else
      puts "!Warning can not remove plugin #{plugin} it is not added"
    end
  end

  private
  def add_plugin_and_nested_plugins(plugin)

    nested_plugins = Dir.entries("#{self.plugin_paths[0]}/#{plugin}/vendor/plugins").map{|directory| directory} rescue nested_plugins = []
    nested_plugins.delete_if{|name| name =~ /^\./}
    nested_plugins = nested_plugins.to_sym

    self.plugins = self.plugins | nested_plugins | [plugin]
  end

  def add_all_non_added_plugins()
    located_plugins = []
    initializer = Rails::Initializer.new(self)
    self.plugin_locators.each do |locator_klass|
      locator = locator_klass.new(initializer)
      located_plugins = located_plugins | locator.plugins
    end

    plugin_names = located_plugins.collect{|p| p.name}
    plugin_names.delete_if{|name| name =~ /^\./}
    plugin_names = plugin_names.to_sym

    plugin_names.delete_if{|name|
      added_plugins = self.plugins

      added_plugins.include?(name.to_sym)
    }

    self.plugins = self.plugins | plugin_names
  end

  def dependencies_exist?(dependencies)
    result = true

    dependencies.each do |dependency|
      result = plugin_exists?(dependency)
      unless result 
        break
      end
    end
    
    result
  end

  def plugin_exists?(plugin)
    self.plugins.include?(plugin)
  end

  #######################################################################################
  #End
  #######################################################################################
end

Rails::Initializer.class_eval do
  class << self
    def run_with_plugin_environments(command = :process, configuration = Rails::Configuration.new, &block)
      Rails.configuration = configuration
      load_plugin_environments
      run_without_plugin_environments(command, configuration, &block)
    end
    alias :run_without_plugin_environments :run
    alias :run :run_with_plugin_environments

    def configure
      yield Rails.configuration
    end

    protected

    def load_plugin_environments
      paths = Dir["{#{Rails.configuration.plugin_paths.join(',')}}/*/config/environment.rb"]
      paths.each { |path| require path }
    end
  end
end

