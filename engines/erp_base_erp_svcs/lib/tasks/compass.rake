# compass installer rake tasks

namespace :compass do
  namespace :install do
  	
  	# Compass Core consists of:
  	# erp_base_svcs
  	# erp_tech_services
  	# erp_dev_svcs
  	# erp_app
    
  	desc 'install compass core engines'
    task :core do
      puts ("\nInstall Compass Core")
      ENV['engines'] = %w(erp_base_erp_svcs erp_tech_services erp_dev_svcs erp_app).join(',')
      ENV['plugins'] = 'data_migrator'
      Rake::Task['compass:install'].invoke
      #copy the compass index page
      FileUtils.cp "vendor/plugins/erp_app/public/index.html", "public/"
      puts "\n\nInstallation Complete."
    end #task :core

   # desc 'install all compass engines and plugins'
   # task :all do
   #   ENV['engines'] = 'all'
   #   ENV['plugins'] = 'all'
   #   Rake::Task['compass:install'].invoke
   # end #task :all
    
    desc "install the Compass Framework and all eCommerce related engines and plugins"
	#task :default => ["compass:install:core"]  do |t, args|
    task :default   do |t, args|              
      Rake::Task['compass:install:default_no_core'].invoke
      #copy the compass index page
      FileUtils.cp "vendor/plugins/erp_app/public/index.html", "public/"
      puts "\n\nInstallation Complete."
    end #task :default
     
    desc "install only the eCommerce related engines and plugins"
	task :default_no_core  do |t, args|
      puts "\nInstall Compass Default (eCommerce Base) Installation\n\n"
      
      ENV['engines'] = %w(erp_base_erp_svcs erp_tech_services erp_dev_svcs erp_app after_commit data_orchestrator erp_agreements erp_commerce erp_communication_events erp_inventory erp_orders erp_products erp_rules erp_search erp_txns_and_accts ext_scaffold master_data_management).join(',')
      ENV['plugins'] = ''
      Rake::Task['db:migrate'].reenable
      # re-enable the compass install task if it has been run previously
      Rake::Task["compass:install"].reenable
      Rake::Task['compass:install'].invoke
    end #task :default_no_core	
     
    desc "install the Compass Framework and all Timeshare related engines and plugins"
	# task :timeshare => ["compass:install:core"]  do |t, args|
    task :timeshare   do |t, args|
       puts "\nCompass Framework and the Timeshare base Installation\n\n"
       
       Rake::Task['compass:install:timeshare_no_core'].invoke	
       
       #copy the compass index page
       FileUtils.cp "vendor/plugins/erp_app/public/index.html", "public/"	
       
       puts "\n\n Installation Complete"
	end #task :timeshare
     
    desc "install the Compass Framework and all Timeshare related engines and plugins"
	task :timeshare_no_core  do |t, args|
       puts "\nCompass Framework and the Timeshare base Installation\n\n"
       # install the common core
       puts "Install only the Timeshare related engines and plugins"
       ENV['engines'] = 'erp_base_erp_svcs erp_tech_services erp_dev_svcs erp_app timeshare'
       ENV['plugins'] = ''
       Rake::Task['db:migrate'].reenable
       Rake::Task["compass:install"].reenable
       Rake::Task['compass:install'].invoke		
       
    end #task :timeshare_no_core
    
  end

  namespace :uninstall do
    desc 'uninstall compass core engines'
    task :core do
      ENV['engines'] = %w(erp_base_erp_svcs erp_tech_services erp_dev_svcs erp_app data_migrator).join(',')
      Rake::Task['compass:uninstall'].invoke
    end #task uninstall:core

    desc 'uninstall all compass engines and plugins'
    task :all do
      ENV['engines'] = 'all'
      ENV['plugins'] = 'all'
      Rake::Task['compass:uninstall'].invoke
	end #task uninstall:all
  end

  desc 'install selected compass engines (pick some with engines=all plugins=all or engines=name1,name2 plugins=name3)'
  task :install do
  	# call the perform method set to :install
    perform(:install)
    
    # call the database migration task
    Rake::Task['db:migrate'].invoke
    Rake::Task['compass:assets:install'].invoke
    
  end

  desc 'uninstall selected compass engines (pick some with engines=all plugins=all or engines=name1,name2 plugins=name3)'
  task :uninstall do
  	# call the perform set to :uninstall
    perform(:uninstall)
  end

  namespace :assets do
    if Rake.application.unix?
      desc "Symlinks public assets from plugins to public/"
    else
      desc "Copy public assets from plugins to public/"
    end
    task :install do
      if Rake.application.unix?
        symlink_plugins
      elsif Rake.application.windows?
        copy_plugins
      else
        raise 'unknown system platform'
      end
    end


    # creates a symbolic link to the plugin rather than forcing a local copy

    def symlink_plugins
      puts "Symlinks public assets from plugins to public/"
      target_dir = "public"
      sources = Dir["vendor/plugins/{*,*/**}/public/*/*"] +
        Dir["vendor/plugins/{*,*/**}/vendor/plugins/**/public/*/*"]

      sources.each do |source|
        split = source.split('/')
        folder, type = split[-1], split[-2]
        target = "#{target_dir}/#{type}/#{folder}"
        relative_source = Pathname.new(source).relative_path_from(Pathname.new("#{target_dir}/#{type}")).to_s
        # TODO: is this necessary? it seems so ...
        FileUtils.rm_rf target if File.exists?(target) || File.symlink?(target)
        FileUtils.mkdir_p(File.dirname(target))
        test = FileUtils.ln_s relative_source, target, :force => true # :verbose => true
        print "."
      end
      print "Done\n"
    end

    # copies the plugin for platforms that dont support symbolic link
    
    def copy_plugins
      target = "#{Rails.root}/public/"
      sources = Dir["#{Rails.root}/vendor/plugins/{*,*/**}/public/*"] +
        Dir["#{Rails.root}/vendor/plugins/{*,*/**}/vendor/plugins/**/public/*"]

      FileUtils.mkdir_p(target) unless File.directory?(target)
      FileUtils.cp_r sources, target
    end

    if not Rake.application.unix?
      desc "Copy assets from public to their respective engines"
      task :backport => :environment do
        if Rake.application.unix?
          raise 'no need to backport on unix - directories are symlinked!'
        elsif Rake.application.windows?
          sources = Dir["#{Rails.root}/public/{images,javascripts,stylesheets}/*"]
          sources.select { |s| File.directory?(s) }.each do |source|
            path = source.gsub("#{Rails.root}/public/", '')
            # determine asset type and owning plugin
            type, plugin_name = path.split('/')
            plugin = Rails.plugins[plugin_name.to_sym]
            if plugin
              target = "#{plugin.directory}/public/#{type}"
              FileUtils.mkdir_p(target) unless File.directory?(target)
              FileUtils.cp_r source, target
            end
          end
        else
          raise 'unknown system platform'
        end
      end
    end
  end

 # the perform method is the workhorse of the installer it retrieves engines and plugins from
 # the environment through ENV

  def perform(method)
    except = ENV['except'] ? ENV['except'].split(',') : []
    core = %w(erp_base_erp_svcs erp_tech_services erp_dev_svcs erp_app data_migrator)

    %w(engines plugins).each do |type|
      if ENV[type]
        names = ENV[type] == 'all' ? all(type) : ENV[type].split(',')
        names -= core if ENV[type] == 'all' && method == :uninstall
        names -= except
        unless ENV[type].nil?
          puts "#{method}ing #{type}: #{names.join(', ')}"
          send(method, type, names)
        end
      end
    end
  end

  def install(type, plugins)
    FileUtils.mkdir_p(target) unless File.exists?(target)
    sources = plugins.map { |engine| source(type, engine) }
    
    if Rake.application.unix?
      FileUtils.ln_s sources, target, :force => true
    elsif Rake.application.windows?
      FileUtils.cp_r sources, target
    else
      raise 'unknown system platform'
    end
  end

  def uninstall(type, plugins)
    plugins.each do |plugin|
      FileUtils.rm_r "#{target}/#{plugin}" rescue Errno::ENOENT
    end
  end

  def all(type)
    Dir["#{absolute_source(type)}/*"].map { |path| File.basename(path) }
  end

  def rails_root
    @rails_root ||= Rake.application.find_rakefile_location.last
  end

  def source(type, subdir = nil)
    "#{rails_root}/vendor/compass/#{type}" + (subdir ? "/#{subdir}" : '')
  end

  def absolute_source(type, subdir = nil)
    "#{rails_root}/vendor/compass/#{type}" + (subdir ? "/#{subdir}" : '')
  end

  def target
    "#{rails_root}/vendor/plugins"
  end
  
  # tasks for seeding the initial install
  
  namespace :bootstrap do
 
   		desc "execute the bootstrap data migrations"
			task :data  do |t, args|
      			puts "Create Bootstrap Data\n\n"
      			puts "Copy ignored data migrations..."
        		Rake::Task["compass:bootstrap:copy_ignored_data_migrations"].invoke (":default")
        		puts "Run Data Migrations..."
        		Rake::Task["db:migrate_data"].invoke
        		puts "Delete Data Migrations..."
        		Rake::Task["compass:bootstrap:delete_data_migrations"].invoke (":default")
     		end #task :data
 
    	desc "move data migrations from ignore directory to its parent"
    		# This task will allow you to move up to five plugin data_migration ignore files
    		task :copy_ignored_data_migrations, :arg1, :arg2, :arg3 ,:arg4, :arg5  do |t, args|
     		
    		#TODO- Can Rake take variable argument list without pre-defining argument symbols
      
       
      		if(args[:arg1]==":default")
      			# TODO- Consider creating array of plugins dynamically
        		plugins=["erp_app","erp_base_erp_svcs","erp_tech_services"]
        		 
        		puts "USING DEFAULT PLUGIN SET: #{plugins.join ', '}"
        		 
      		else
        		plugins =Array.new
        		if (args[:arg1]!=nil) 
         			plugins<<args[:arg1] 
        		end
        		if (args[:arg2]!=nil) 
          			plugins<<args[:arg2] 
		        end
		        if (args[:arg3]!=nil) 
		          plugins<<args[:arg3]
		        end
		        if (args[:arg4]!=nil) 
		         plugins<<args[:arg4] 
		        end
		        if (args[:arg5]!=nil) 
		         plugins<<args[:arg5] 
		        end
      		end  
      		
      		# if no plugins were supplied use the defaults  
		    if(plugins.length==0)
		    	puts "\nNo plugins arguments supplied.\n\nYou can supply up to five plugins\n\nRAKE TASK ARGUMENT FORM:\n\n"
		        puts "rake db:move_ignored_data_migrations[:default]- moves DEFAULT plugin data migrations"
		        puts "rake db:move_ignored_data_migrations[erp_app,erp_tech_services]- moves plugin for erp_app and erp_tech_services"
		        puts "\n\n EXITING RAKE TASK."
		        exit 1
		    end # plugin.length=0    
     
       		puts "Moving data migrations from 'ignore' directory to parent\n\n"
       
      
      		# loop over the plugins and check if the plugin exists
      		for idx in 0...plugins.length
      
      			if(plugins[idx]!=nil)
      				puts "Processing [#{plugins[idx]}] plugin\n"
        			if(File.exists?("./vendor/plugins/#{plugins[idx]}/db/data_migrations/ignore"))
        
          				data_migrations=Dir.entries("./vendor/plugins/#{plugins[idx]}/db/data_migrations/ignore")
      	  				moved_file_counter=0;  
          
      	  				for idx2 in 0...data_migrations.length
      	    				data_migration_filename= data_migrations[idx2]
      	    				if(data_migration_filename.starts_with?("."))
      	     					## skip
  	    					else
  	      						#copy the data migration from the ignore file to it's parent
  	     						puts "\n\nMoving #{data_migration_filename} TO ./vendor/plugins/#{plugins[idx]}/db/data_migrations"
  	     						FileUtils.copy("./vendor/plugins/#{plugins[idx]}/db/data_migrations/ignore/#{data_migration_filename}",
  	                         		"./vendor/plugins/#{plugins[idx]}/db/data_migrations/#{data_migration_filename}")
					      	    moved_file_counter=moved_file_counter+1                   
					      	    # delete the original
					      	    ## puts "Deleting ./vendor/plugins/#{plugins[idx]}/db/data_migrations/ignore/#{data_migration_filename}"
					      	    ## File.delete("./vendor/plugins/#{plugins[idx]}/db/data_migrations/ignore/#{data_migration_filename}")
					      	                         
				      	    end
      	    
          				end
          				puts "Copied (#{moved_file_counter}) data migrations\n\n"
      	  
			      	else
			      	  puts "./vendor/plugins/"+plugins[idx]+"/db/data_migrations/ignore DIRECTORY IS EMPTY"
			      	end
       			end	
  		    end # plugin loop
      
		end# task :copy_ignored_data_migrations
		
		desc "delete data migrations from directory to its parent"
    		# This task deletes the data migrations in the specified plugins
    		task :delete_data_migrations, :arg1, :arg2, :arg3 ,:arg4, :arg5  do |t, args|
     		
    		#TODO- Can Rake take variable argument list without pre-defining argument symbols
      
       
      		if(args[:arg1]==":default")
      			# TODO- Consider creating array of plugins dynamically
        		plugins=["erp_app","erp_base_erp_svcs","erp_tech_services"]
        		 
        		puts "USING DEFAULT PLUGIN SET: #{plugins.join ', '}"
        		 
      		else
        		plugins =Array.new
        		if (args[:arg1]!=nil) 
         			plugins<<args[:arg1] 
        		end
        		if (args[:arg2]!=nil) 
          			plugins<<args[:arg2] 
		        end
		        if (args[:arg3]!=nil) 
		          plugins<<args[:arg3]
		        end
		        if (args[:arg4]!=nil) 
		         plugins<<args[:arg4] 
		        end
		        if (args[:arg5]!=nil) 
		         plugins<<args[:arg5] 
		        end
      		end  
      		
      		# if no plugins were supplied use the defaults  
		    if(plugins.length==0)
		    	puts "\nNo plugins arguments supplied.\n\nYou can supply up to five plugins\n\nRAKE TASK ARGUMENT FORM:\n\n"
		        puts "rake db:move_ignored_data_migrations[:default]- moves DEFAULT plugin data migrations"
		        puts "rake db:move_ignored_data_migrations[erp_app,erp_tech_services]- moves plugin for erp_app and erp_tech_services"
		        puts "\n\n EXITING RAKE TASK."
		        exit 1
		    end # plugin.length=0    
     
       		puts "Deleting data migrations \n\n"
       
      
      		# loop over the plugins and check if the plugin exists
      		for idx in 0...plugins.length
      
      			if(plugins[idx]!=nil)
      				puts "Processing [#{plugins[idx]}] plugin\n"
        			 
          				data_migrations=Dir.entries("./vendor/plugins/#{plugins[idx]}/db/data_migrations")
      	  				deleted_file_counter=0;  
          
      	  				for idx2 in 0...data_migrations.length
      	    				data_migration_filename= data_migrations[idx2]
      	    				if(data_migration_filename.ends_with?(".rb"))
      	     				 
  	      						
					      	    deleted_file_counter=deleted_file_counter+1                   
					      	    # delete the original
					      	    puts "Deleting ./vendor/plugins/#{plugins[idx]}/db/data_migrations/#{data_migration_filename}"
					      	    File.delete("./vendor/plugins/#{plugins[idx]}/db/data_migrations/#{data_migration_filename}")
					      	                         
				      	    end
      	    
          				end
          				puts "deleted (#{deleted_file_counter}) data migrations\n\n"
      	  
			      	 
       			end	
  		    end # plugin loop
      
		end# task :delete_ignored_data_migrations
	end # bootstrap namespace
end

Rake::Task["db:migrate"].clear_actions


namespace :db do
  task :migrate do
  	#puts "\n\ninvoking db:migrate..."
  	Rake::Task["db:migrate:prepare_migrations"].reenable
    Rake::Task["db:migrate:prepare_migrations"].invoke
    
    Rake::Task["db:migrate:original_migrate"].reenable
    Rake::Task["db:migrate:original_migrate"].invoke
    
    Rake::Task["db:migrate:cleanup_migrations"].reenable
    Rake::Task["db:migrate:cleanup_migrations"].invoke
    puts "completed db:migrate\n\n"
  end

  namespace :migrate do
    
    desc "Copy migrations from plugins to db/migrate"
    task :prepare_migrations do
      
      target = "#{Rails.root}/db/migrate/"
      puts "\n\npreparing migrations in: #{target}}\n"
      # first copy all app migrations away
      files = Dir["#{target}*.rb"]

      unless files.empty?
        FileUtils.mkdir_p "#{target}app/"
        FileUtils.cp files, "#{target}app/", { :verbose => true}
        puts "copied #{files.size} migrations to db/migrate/app"
      end

      dirs = Rails.plugins.values.map(&:directory)
      files = Dir["{#{dirs.join(',')}}/db/migrate/*.rb"]

      unless files.empty?
        FileUtils.mkdir_p target
        FileUtils.cp files, target #, { :verbose => true}
        puts "copied #{files.size} migrations to db/migrate"
      end
    end#end task
    
    
    task :original_migrate do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate("db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
    
    desc "Cleanup Migrations"
    task :cleanup_migrations do
      target = "#{Rails.root}/db/migrate"
      files = Dir["#{target}/*.rb"]
      unless files.empty?
        FileUtils.rm files
        puts "removed #{files.size} migrations from db/migrate"
      end
      files = Dir["#{target}/app/*.rb"]
      unless files.empty?
        FileUtils.cp files, target
        puts "copied #{files.size} migrations back to db/migrate"
      end
      FileUtils.rm_rf "#{target}/app"
    end
    
  end
  
  
end
