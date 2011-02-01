require 'ActiveSupport'

Rails::Generator::Commands::Create.class_eval do
  def route_resources_with_route_file(route_file_path='config/routes.rb', *resources)
    resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
    sentinel = '#generated_routes'
    logger.route "map.resources #{resource_list}"
    gsub_file route_file_path, /(#{Regexp.escape(sentinel)})/mi do |match|
      "#{match}\n  map.resources #{resource_list}\n"
    end
  end
end

class ActiveExtGenerator < Rails::Generator::NamedBase
  @icon = nil
  @description = nil
  @plugin = nil

  def initialize(runtime_args, runtime_options = {})
    super
    raise "Must Include Container Arg[1]" if runtime_args[1].blank?
    raise "Must Include Application Arg[2]" if runtime_args[2].blank?
    @container     = runtime_args[1]
    @application   = runtime_args[2]
    @plugin        = runtime_args[3].blank? ? 'erp_app' : runtime_args[3]
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions "#{class_name}Controller"

      #Controller
      m.template "controllers/controller_template.rb", "vendor/plugins/#{@plugin}/app/controllers/erp_app/#{container_file_name}/#{application_file_name}/#{file_name}_controller.rb"

      #public
      #make javascript source and app folder
      m.template "public/module.js.erb", "vendor/plugins/#{@plugin}/public/javascripts/erp_app/#{container_file_name}/applications/#{application_file_name}/#{file_name}_editable_grid.js"

      logger.info "creating route ~ map.connect '/erp_app/#{container_file_name}/#{application_file_name}/#{file_name}/:action', :controller => 'erp_app/erp_app/#{container_file_name}/#{application_file_name}/#{file_name}'"
      sentinel = "##{application_file_name}"
      m.gsub_file 'vendor/plugins/erp_app/config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
        "#{match}\n  map.connect '/erp_app/#{container_file_name}/#{application_file_name}/#{file_name}/:action', :controller => 'erp_app/#{container_file_name}/#{application_file_name}/#{file_name}'"
      end

      #Readme
      m.readme "INSTALL"
    end
  end

  def application_file_name
    @application.underscore
  end

  def application_class_name
    @application.classify
  end

  def container_file_name
    @container.underscore
  end

  def container_class_name
    @container.classify
  end
end
