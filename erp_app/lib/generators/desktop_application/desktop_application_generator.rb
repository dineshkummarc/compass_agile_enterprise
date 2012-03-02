class DesktopApplicationGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  argument :description, :type => :string 
  argument :icon, :type => :string 

  def generate_desktop_application
    #Controller
    template "controllers/controller_template.rb", "app/controllers/erp_app/desktop/#{file_name}/base_controller.rb"

    #make javascript
    template "public/module.js.erb", "public/javascripts/erp_app/desktop/applications/#{file_name}/module.js"

    #make css folder
    empty_directory "public/stylesheets/erp_app/desktop/applications/#{file_name}"

    #make images folder
    empty_directory "public/images/erp_app/desktop/applications/#{file_name}"
    
    #add route
    route "match '/erp_app/desktop/#{file_name}(/:action)' => \"erp_app/desktop/#{file_name}/base\""
    
    #migration
    template "migrate/migration_template.rb", "db/data_migrations/#{RussellEdge::DataMigrator.next_migration_number}_create_#{file_name}_desktop_application.rb"
  end
end
