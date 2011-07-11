class ErpApp::ApplicationResourceLoader::FileSystemLoader
  @javascripts_folder = nil
  @stylesheets_folder = nil

  def initialize(application)
    @application = application
  end

  def load_resources
    @app_name = @application.internal_identifier
    
    if @application.type == 'DesktopApplication'
      @app_type = 'desktop'
    else
      @app_type = 'organizer'
    end

    resource_string = ''
    resource_string = locate_resources('js', resource_string)
    resource_string = locate_resources('css', resource_string)

    resource_string
  end

  private

  def locate_resources(resource_type, resource_string)
    plugin_names = Rails.plugins.collect{|item| item.first}

    files = []
    plugin_names.each do |plugin_name|
      #get all files based on resource type we are loading
      case resource_type
      when 'js'
        files = Dir.glob(File.join(Rails.root,"/vendor/plugins/#{plugin_name.to_s}/public/javascripts/erp_app/#{@app_type}/applications/",@app_name,"*.#{resource_type}"))
      when 'css'
        files = Dir.glob(File.join(Rails.root,"/vendor/plugins/#{plugin_name.to_s}/public/stylesheets/erp_app/#{@app_type}/applications/",@app_name,"*.#{resource_type}"))
      end

      break unless files.empty?
    end

    files = files.collect{|file| File.basename(file)}

    #make sure the base js file is loaded before all others
    if resource_type == 'js'
      if @app_type == 'desktop'
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
        resource_string << "<script type='text/javascript' src='/javascripts/erp_app/#{@app_type}/applications/#{@app_name}/#{file}'></script>"
      when 'css'
        resource_string << "<link href='/stylesheets/erp_app/#{@app_type}/applications/#{@app_name}/#{file}' media='screen' rel='stylesheet' type='text/css' />"
      end
    end

    resource_string
  end

end
