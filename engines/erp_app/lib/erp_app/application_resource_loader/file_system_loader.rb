class ErpApp::ApplicationResourceLoader::FileSystemLoader
  @javascripts_folder = nil
  @stylesheets_folder = nil

  def initialize(application)
    @application = application
  end

  def load_resources
    app_name = @application.internal_identifier
    app_type = nil
    if @application.type == 'DesktopApplication'
      app_type = 'desktop'
      @javascripts_folder = '/vendor/plugins/erp_app/public/javascripts/erp_app/desktop/applications'
      @stylesheets_folder = '/vendor/plugins/erp_app/public/stylesheets/erp_app/desktop/applications'
    else
      app_type = 'organizer'
      @javascripts_folder = '/vendor/plugins/erp_app/public/javascripts/erp_app/organizer/applications'
      @stylesheets_folder = '/vendor/plugins/erp_app/public/stylesheets/erp_app/organizer/applications'
    end

    resource_string = ''
    resource_string = locate_resources(app_name, app_type, 'js', resource_string)
    resource_string = locate_resources(app_name, app_type, 'css', resource_string)

    resource_string
  end

  private

  def locate_resources(app_name, app_type, resource_type, resource_string)
    #get all files based on resource type we are loading
    case resource_type
    when 'js'
      files = Dir.glob(File.join(Rails.root,@javascripts_folder,app_name,"*.#{resource_type}"))
    when 'css'
      files = Dir.glob(File.join(Rails.root,@stylesheets_folder,app_name,"*.#{resource_type}"))
    end

    files = files.collect{|file| File.basename(file)}

    #make sure the base js file is loaded before all others
    if resource_type == 'js'
      if app_type == 'desktop'
        index = files.index{|x| x =~ /module.js/}
      else
        index = files.index{|x| x =~ /base.js/}
      end
      
      first_load_js = files[index]
      files.delete_at(index)
      files.push(first_load_js)
      files.reverse!
    end

    #append the resource to our resource string
    files.each do |file|
      case resource_type
      when 'js'
        resource_string << "<script type='text/javascript' src='/javascripts/erp_app/#{app_type}/applications/#{app_name}/#{file}'></script>"
      when 'css'
        resource_string << "<link href='/stylesheets/erp_app/#{app_type}/applications/#{app_name}/#{file}' media='screen' rel='stylesheet' type='text/css' />"
      end
    end

    resource_string
  end

end
