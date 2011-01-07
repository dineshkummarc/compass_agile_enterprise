class ErpApp::ApplicationResourceLoader::FileSystemLoader
  @javascripts_folder = nil
  @stylesheets_folder = nil

  def initialize(application)
    @application = application
  end

  def load_resources
    app_name = @application.internal_identifier

    resource_string = ''
    resource_string = locate_resources(app_name, 'js', resource_string)
    resource_string = locate_resources(app_name, 'css', resource_string)

    resource_string
  end

  private

  def locate_resources(app_name, resource_type, resource_string)
    #get all files based on resource type we are loading
    case resource_type
    when 'js'
      files = Dir.glob(File.join(Rails.root,@javascripts_folder,app_name,"*.#{resource_type}"))
    when 'css'
      files = Dir.glob(File.join(Rails.root,@stylesheets_folder,app_name,"*.#{resource_type}"))
    end

    files = files.collect{|file| File.basename(file)}

    #append the resource to our resource string
    files.each do |file|
      case resource_type
      when 'js'
        resource_string << "<script type='text/javascript' src='/javascripts/erp_app/desktop/applications/#{app_name}/#{file}'></script>"
      when 'css'
        resource_string << "<link href='/stylesheets/erp_app/desktop/applications/#{app_name}/#{file}' media='screen' rel='stylesheet' type='text/css' />"
      end
    end

    resource_string
  end

end
