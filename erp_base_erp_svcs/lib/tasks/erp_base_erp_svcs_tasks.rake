namespace :compass do
  namespace :install do
  	
  	# Compass Core consists of:
  	# erp_base_svcs
  	# erp_tech_services
  	# erp_dev_svcs
  	# erp_app
    
  	desc 'install compass core engines'
    task :core do
      puts("\nInstalling Compass Core")
      ENV['engines'] = %w(erp_base_erp_svcs erp_tech_services erp_dev_svcs erp_app knitkit rails_db_admin erp_forms).join(',')
      ENV['plugins'] = %w(data_migrator).join(',')
      Rake::Task['compass:install'].invoke
      
      puts "\n\nInstallation Complete."
    end
    
    desc "install all of the Compass Framework"
    task :all do |t, args|
      puts("\nInstalling All Compass Engines")
      ENV['engines'] = %w(rails_db_admin knitkit erp_base_erp_svcs erp_tech_services erp_dev_svcs erp_app erp_agreements erp_financial_accounting erp_commerce erp_communication_events erp_inventory erp_orders erp_products erp_rules erp_search erp_txns_and_accts erp_work_effort erp_forms).join(',')
      ENV['plugins'] = %w(data_migrator).join(',')
      Rake::Task['compass:install'].invoke

      puts "\n\nInstallation Complete."
    end

    desc "install Timeshare related engines and plugins"
    # task :timeshare => ["compass:install:core"]  do |t, args|
    task :timeshare   do |t, args|
      puts "\nnInstalling Compass Timeshare Engine\n\n"
      ENV['engines'] = %w(timeshare)
      Rake::Task['compass:install'].invoke
       
      puts "\n\n Installation Complete"
    end #task :timeshare
  end

  namespace :uninstall do
    desc 'uninstall compass core engines'
    task :core do
      ENV['engines'] = %w(rails_db_admin erp_base_erp_svcs erp_tech_services erp_dev_svcs erp_app knitkit data_migrator).join(',')
      Rake::Task['compass:uninstall'].invoke
    end #task uninstall:core

    desc 'uninstall all compass engines and plugins'
    task :all do
      ENV['engines'] = %w(drails_db_admin ata_migrator knitkit erp_base_erp_svcs erp_tech_services erp_dev_svcs erp_app erp_agreements erp_commerce erp_communication_events erp_inventory erp_orders erp_products erp_rules erp_search erp_txns_and_accts).join(',')
      Rake::Task['compass:uninstall'].invoke
    end #task uninstall:all
  end

  desc 'install selected compass engines (pick some with engines=all plugins=all or engines=name1,name2 plugins=name3)'
  task :install do
  	# call the perform method set to :install
    perform(:install)
    Rake::Task['db:migrate'].invoke
  end

  desc 'uninstall selected compass engines (pick some with engines=all plugins=all or engines=name1,name2 plugins=name3)'
  task :uninstall do
  	# call the perform set to :uninstall
    perform(:uninstall)
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
    
    if Rake.application.unix?
      plugins.each do  |engine|
        source_path = source(type, engine)
        relative_source = Pathname.new(source_path).relative_path_from(Pathname.new("#{target}/")).to_s
        test = FileUtils.ln_s relative_source, "#{target}/#{engine}", :force => true # :verbose => true
      end 
    elsif Rake.application.windows?
      sources = plugins.map { |engine| source(type, engine) }
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
 
    desc "execute the bootstrap data"
    task :data => :environment   do |t, args|
      ErpApp::Setup::Data.run_setup
      Rake::Task['db:migrate_data'].invoke
    end #task :data
	end # bootstrap namespace

  namespace :update do
    desc "update current compass install"
    task :run => :environment do
      Dir.chdir( File.join(rails_root,"vendor/compass/engines") )
      puts `git pull`
      Dir.chdir( rails_root )
      
      Rake::Task["db:migrate"].invoke
      Rake::Task["db:migrate_data"].invoke

      begin
        file = File.new("#{rails_root}/vendor/compass/engines/erp_base_erp_svcs/lib/tasks/release_notes/NOTES", "r")
        while (line = file.gets)
          puts "#{line}"
        end
        file.close
      rescue => err
        puts "Exception: #{err}"
        err
      end
    end

  end

end

Rake::Task["db:migrate"].clear_actions

namespace :db do
  task :migrate do
  	begin
  	  Rake::Task["db:migrate:prepare_migrations"].reenable
      Rake::Task["db:migrate:prepare_migrations"].invoke
    
      Rake::Task["db:migrate:original_migrate"].reenable
      Rake::Task["db:migrate:original_migrate"].invoke
    
      Rake::Task["db:migrate:cleanup_migrations"].reenable
      Rake::Task["db:migrate:cleanup_migrations"].invoke
    rescue Exception=>ex
      Rake::Task["db:migrate:cleanup_migrations"].reenable
      Rake::Task["db:migrate:cleanup_migrations"].invoke
      raise ex
    end
  end

  namespace :migrate do
    
    desc "list pending migrations"
    task :list_pending => :environment do
      Rake::Task["db:migrate:prepare_migrations"].reenable
      Rake::Task["db:migrate:prepare_migrations"].invoke

      pending_migrations = ActiveRecord::Migrator.new('up', 'db/migrate/').pending_migrations.collect{|item| File.basename(item.filename)}
      puts "================Pending Migrations=========="
      puts pending_migrations
      puts "================================================="

      Rake::Task["db:migrate:cleanup_migrations"].reenable
      Rake::Task["db:migrate:cleanup_migrations"].invoke
    end

    desc "Copy migrations from plugins to db/migrate"
    task :prepare_migrations do
      
      target = "#{Rails.root}/db/migrate/"
      # first copy all app migrations away
      files = Dir["#{target}*.rb"]

      unless files.empty?
        FileUtils.mkdir_p "#{target}app/"
        FileUtils.cp files, "#{target}app/"
        puts "copied #{files.size} migrations to db/migrate/app"
      end

      dirs = Rails::Application::Railties.engines.map{|p| p.config.root.to_s}
      files = Dir["{#{dirs.join(',')}}/db/migrate/*.rb"]

      unless files.empty?
        FileUtils.mkdir_p target
        FileUtils.cp files, target
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
