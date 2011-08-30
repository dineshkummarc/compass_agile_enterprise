Rake::Task["db:migrate"].clear_actions

namespace :db do
  task :migrate do
  	Rake::Task["db:migrate:prepare_migrations"].reenable
    Rake::Task["db:migrate:prepare_migrations"].invoke
    
    Rake::Task["db:migrate:original_migrate"].reenable
    Rake::Task["db:migrate:original_migrate"].invoke
    
    Rake::Task["db:migrate:cleanup_migrations"].reenable
    Rake::Task["db:migrate:cleanup_migrations"].invoke
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
