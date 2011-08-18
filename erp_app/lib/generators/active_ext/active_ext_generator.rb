class ActiveExtGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  argument :container, :type => :string 
  argument :application, :type => :string
  
  def generate_active_ext
    #check_class_collision :suffix => "Controller"
    
    #controller
    template "controllers/controller_template.rb", File.join("app/controllers/erp_app",container_file_name,application_file_name,"#{file_name}_controller.rb")
    
    #javascript
    template "public/module.js.erb", File.join("public/javascripts/erp_app",container_file_name,"applications",application_file_name,"#{file_name}_active_ext.js")
  
    #views
    for action in scaffold_views
      copy_file "views/#{action}.html.erb", File.join('app/views/erp_app', container_file_name, application_file_name, file_name, "#{action}.html.erb")
    end
    
    #route
    route "match \"/erp_app/#{container_file_name}/#{application_file_name}/#{file_name}/:action(/:id)\" => \"erp_app/#{container_file_name}/#{application_file_name}/#{file_name}#index\""
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

  def scaffold_views
    %w[create edit new show update]
  end
end
