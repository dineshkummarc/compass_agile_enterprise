Rake::Task["db:migrate"].clear_actions

namespace :db do
  task :migrate => :environment do
    ActiveRecord::Migrator.prepare_migrations
    Rake::Task["db:migrate:original_migrate"].reenable
    Rake::Task["db:migrate:original_migrate"].invoke
    ActiveRecord::Migrator.cleanup_migrations
  end

  namespace :migrate do
    
    desc "list pending migrations"
    task :list_pending => :environment do
      ActiveRecord::Migrator.prepare_migrations
      pending_migrations = ActiveRecord::Migrator.new('up', 'db/migrate/').pending_migrations.collect{|item| File.basename(item.filename)}
      puts "================Pending Migrations=========="
      puts pending_migrations
      puts "============================================"
      ActiveRecord::Migrator.cleanup_migrations
    end
    
    desc "original migrate"
    task :original_migrate do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate("db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
    
  end#migrate
end#db

namespace :compass_ae do

  desc "Upgrade you installation of Compass AE"
  task :upgrade => :environment do
    begin
      ActiveRecord::Migrator.prepare_upgrade_migrations
      RussellEdge::DataMigrator.prepare_upgrade_migrations

      Rake::Task["db:migrate"].reenable
      Rake::Task["db:migrate"].invoke

      Rake::Task["db:migrate_data"].reenable
      Rake::Task["db:migrate_data"].invoke

      ActiveRecord::Migrator.cleanup_upgrade_migrations
      RussellEdge::DataMigrator.cleanup_upgrade_migrations
    rescue Exception=>ex
      ActiveRecord::Migrator.cleanup_migrations
      ActiveRecord::Migrator.cleanup_upgrade_migrations
      RussellEdge::DataMigrator.cleanup_upgrade_migrations

      puts ex.inspect
      puts ex.backtrace
    end
  end

end
