require 'action_view'

module ErpApp
  module ApplicationResourceLoader
		class SharedLoader < ErpApp::ApplicationResourceLoader::BaseLoader
      
		  def locate_shared_files(resource_type, folder='shared')
  		  engine_dirs = Rails::Application::Railties.engines.map{|p| p.config.root.to_s}
        root_and_engines_dirs = ([Rails.root] | engine_dirs)

				# get shared resources (global js and css)
  			shared_files = []
  			root_and_engines_dirs.each do |engine_dir|
    			if File.exists? File.join(engine_dir,"public/#{resource_type.to_s}/erp_app", folder)
    		    shared_path = File.join(engine_dir,"public/#{resource_type.to_s}/erp_app", folder,"**/*.#{(resource_type == :javascripts) ? 'js' : 'css'}")
    		    paths = Dir.glob(shared_path)
            shared_files = (shared_files | paths.collect{|path| path.gsub(File.join(engine_dir,'public',resource_type.to_s,'/'),'')}).flatten
    		  end
        end

		    shared_files = sort_files(shared_files)
		  end

		end#SharedLoader
  end#ApplicationResourceLoader
end#ErpApp
