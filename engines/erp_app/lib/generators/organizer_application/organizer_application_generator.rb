class OrganizerApplicationGenerator < Rails::Generator::NamedBase
  @icon = nil
  @description = nil
  @erp_application = nil

  def initialize(runtime_args, runtime_options = {})
    super
    raise "Must Include A Description For This Application Arg[1]" if runtime_args[1].blank?
    raise "Must Include An Image Icon CSS Class For This Application Arg[2]" if runtime_args[2].blank?
    @description     = runtime_args[1]
    @icon            = runtime_args[2]
    @erp_application = runtime_args[3].blank? ? 'erp_app' : runtime_args[2]
  end

  def manifest
    record do |m|

      #Controller
      m.directory "vendor/plugins/#{@erp_application}/app/controllers/erp_app/organizer/#{file_name}"
      m.template "controllers/controller_template.rb", "vendor/plugins/#{@erp_application}/app/controllers/erp_app/organizer/#{file_name}/base_controller.rb"

      #public
      m.directory "vendor/plugins/#{@erp_application}/public/javascripts/erp_app/organizer/applications/#{file_name}"
      m.template "public/base.js.erb", "vendor/plugins/#{@erp_application}/public/javascripts/erp_app/organizer/applications/#{file_name}/base.js"

      #make css app folder
      m.directory "vendor/plugins/#{@erp_application}/public/stylesheets/erp_app/organizer/applications/#{file_name}"

      #make images app folder
      m.directory "vendor/plugins/#{@erp_application}/public/images/erp_app/organizer/applications/#{file_name}"

      #Route
      m.template "routes/route_template.rb", "vendor/plugins/#{@erp_application}/config/#{file_name}_app_routes.rb"

       #Migration
      m.migration_template "migrate/migration_template.rb", "vendor/plugins/#{@erp_application}/db/data_migrations/", {:migration_file_name => "create_organizer_app_#{file_name}"}


      #Readme
      m.readme "INSTALL"
    end
  end

  def description
    @description
  end

  def icon
    @icon
  end
end
