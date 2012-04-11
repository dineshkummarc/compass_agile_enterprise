require 'action_view'

module ErpApp
  module ApplicationResourceLoader
		class MobileLoader < ErpApp::ApplicationResourceLoader::BaseLoader
      
		  def initialize(application)
        @application = application
		  end

		  def locate_resources(resource_type)
        @app_name = @application.internal_identifier

        locate_resource_files(resource_type)
		  end

		  private

		  def locate_resource_files(resource_type)
  		  engine_dirs = Rails::Application::Railties.engines.map{|p| p.config.root.to_s}
        root_and_engines_dirs = ([Rails.root] | engine_dirs)

        application_files = []
  			root_and_engines_dirs.each do |engine_dir|
  			  #get all files based on resource type we are loading for the given application type and application
  			  path = File.join(engine_dir,"public/#{resource_type}/erp_app/mobile/applications",@app_name)
          if File.exists? path
  			    application_path = File.join(path,"**/*.#{(resource_type == 'javascripts') ? 'js' : 'css'}")
  			    application_files = application_files | Dir.glob(application_path)
            application_files.map!{|file| file.gsub(path,'')}
  			  end
  			end

        #make sure the base js file is loaded before all others
  			if resource_type == 'javascripts' && (application_files.index{|x| x =~ /app.js/})
  			  index = application_files.index{|x| x =~ /app.js/}
  			  first_load_js = application_files[index]
  			  application_files.delete_at(index)
  			  application_files.push(first_load_js)
  			end
        application_files.map!{|file| File.join("erp_app/mobile/applications",@app_name,file)}
		  end

		end#MobileLoader
  end#ApplicationResourceLoader
end#ErpApp
