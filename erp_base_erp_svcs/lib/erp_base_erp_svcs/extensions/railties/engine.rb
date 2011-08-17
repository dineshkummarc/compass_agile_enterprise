module Rails
	Engine.class_eval do
	#forces rails to reload models in this engine
    #lib_files_to_reload (array) optional specify acts_as mixins to reload
    def load_extensions
      root_models_path = "#{Rails.root}/app/models/"
      engine_path = self.root.to_s
      engine_models_path = "#{engine_path}/app/models/"
      engine_extensions_path = "#{engine_models_path}extensions/"
      #tables = ActiveRecord::Base.connection.tables

      begin
        #get all files from this engines app/model directory
        model_extension_files = Dir.entries(engine_extensions_path).map{|directory| directory}
        #remove any .svn or .data files
        model_extension_files.delete_if{|name| name =~ /^\./}

        #Must use eval to run each extension so rails picks up the extension
        model_extension_files.each do |filename|
          #check if table exists
          content = File.open(engine_extensions_path + filename) { |f| f.read }
          class_name = filename[0..-4]
          #if tables.include?(class_name.tableize)
            eval(IO.read(engine_extensions_path + filename), binding, engine_extensions_path + filename)
          #end
        end
      end if File.directory? engine_extensions_path

      begin
        #get all files from this engines app/model directory
        model_files = Dir.entries(engine_models_path).map{|directory| directory}
        #remove any .svn or .data files
        model_files.delete_if{|name| name =~ /^\./}
        #exclude the extension directory
        model_files.delete_if{|name| name == "extensions"}

        model_files.each do |filename|
			
          class_name = filename[0..-4]
          klass = class_name.camelize

          #if there is a model in {rails_root}/app/models it needs to be reloaded.
          #used to turn a class declaration into a class eval
          if FileTest.exists?(root_models_path + filename)
            content = File.open(engine_models_path + filename) { |f| f.read }
            #make sure this class extends ActiveRecord::Base
            #we only want to do this for ActiveRecord models
            if content.include? '< ActiveRecord::Base'
              #if tables.include?(class_name.tableize)
                content.gsub!("class #{klass} < ActiveRecord::Base", "#{klass}.class_eval do")
                eval(content, binding)
              #end
            end
          end
        end
      end if File.directory? engine_models_path
    end
  end
end
