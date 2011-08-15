class DesktopApplicationGenerator < Rails::Generator::NamedBase
  @icon = nil
  @description = nil
  @plugin = 'erp_app'

  def initialize(runtime_args, runtime_options = {})
    super
    raise "Must Include A Description For This Application Arg[1]" if runtime_args[1].blank?
    raise "Must Include An Image Icon CSS Class For This Application Arg[2]" if runtime_args[2].blank?
    @description = runtime_args[1]
    @icon        = runtime_args[2]
    @plugin  = runtime_args[3].blank? ? 'erp_app' : runtime_args[3]
  end

  def manifest
    record do |m|

      #Controller
      m.directory "vendor/plugins/#{@plugin}/app/controllers/erp_app/desktop/#{file_name}"
      m.template "controllers/controller_template.rb", "vendor/plugins/#{@plugin}/app/controllers/erp_app/desktop/#{file_name}/base_controller.rb"

      #public
      #make javascript source and app folder
      m.directory "vendor/plugins/#{@plugin}/public/javascripts/erp_app/desktop/applications/#{file_name}"
      m.template "public/module.js.erb", "vendor/plugins/#{@plugin}/public/javascripts/erp_app/desktop/applications/#{file_name}/module.js"

      #make css app folder
      m.directory "vendor/plugins/#{@plugin}/public/stylesheets/erp_app/desktop/applications/#{file_name}"

      #make images app folder
      m.directory "vendor/plugins/#{@plugin}/public/images/erp_app/desktop/applications/#{file_name}"

      logger.info "creating route ~ map.connect '/erp_app/desktop/#{file_name}/:action', :controller => 'erp_app/desktop/#{file_name}/base'"
      sentinel = "#Desktop Applications"
      m.gsub_file 'vendor/plugins/erp_app/config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
        "#{match}\n\n  ##{file_name}\n  map.connect '/erp_app/desktop/#{file_name}/:action', :controller => 'erp_app/desktop/#{file_name}/base'"
      end

      #Migration
      m.migration_template "migrate/migration_template.rb", "vendor/plugins/#{@plugin}/db/data_migrations/", {:migration_file_name => "create_desktop_app_#{file_name}"}

      #Readme
      m.readme "INSTALL"
    end
  end

  def icon
    @icon
  end

  def description
    @description
  end
end
