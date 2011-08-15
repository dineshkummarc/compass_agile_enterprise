require 'action_view'

module ErpApp
	module ApplicationResourceLoader
		class FileSystemLoader 
		  @javascripts_folder = nil
		  @stylesheets_folder = nil

		  def initialize(application)
			@application = application
		  end

		  def locate_resources(resource_type)
			@app_name = @application.internal_identifier
			@app_type = (@application.type == 'DesktopApplication') ? 'desktop' : 'organizer'
			
			locate_resources_in_engines(resource_type)
		  end

		  private

		  def locate_resources_in_engines(resource_type)
			dirs = Rails::Application::Railties.engines.map{|p| p.config.root.to_s}
			paths = [] 
			files = []
			dirs.each do |engine_dir|
			  #get all files based on resource type we are loading for the given application type and application
			  application_path = File.join(engine_dir,"/public/#{resource_type}/erp_app/#{@app_type}/applications/",@app_name,"*.#{(resource_type == 'javascripts') ? 'js' : 'css'}")
			  files = Dir.glob(application_path)
			  break unless files.empty?
			end

			files = files.collect{|file| File.basename(file)}

			#make sure the base js file is loaded before all others
			if resource_type == 'javascripts'
			  index = (@app_type == 'desktop') ? files.index{|x| x =~ /module.js/} : files.index{|x| x =~ /base.js/}
			  first_load_js = files[index]
			  files.delete_at(index)
			  files.push(first_load_js)
			  files.reverse!
			end

			#append the resource to our resource string
			files.map{|file| "erp_app/#{@app_type}/applications/#{@app_name}/#{file}"}
		  end
		end
	end
end
