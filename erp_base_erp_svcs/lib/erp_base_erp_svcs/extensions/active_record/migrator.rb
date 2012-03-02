ActiveRecord::Migrator.instance_eval do
  def prepare_migrations
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
  end
  
  def cleanup_migrations
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

  def prepare_upgrade_migrations
    dirs = Rails::Application::Railties.engines.map{|p| p.config.root.to_s}
    dirs.each do |dir|
      if File.directory? File.join(dir,'db/migrate/upgrade')
        target = File.join(dir,'db/migrate/')
        files = Dir["#{target}*.rb"]
        unless files.empty?
          FileUtils.mkdir_p "#{target}app/"
          FileUtils.cp files, "#{target}app/"
          puts "copied #{files.size} upgrade migrations to #{target}app"
        end

        files = Dir["#{File.join(dir,'db/migrate/upgrade')}/*.rb"]
        FileUtils.cp files, File.join(dir,'db/migrate/')
      end
    end
  end

  def cleanup_upgrade_migrations
    dirs = Rails::Application::Railties.engines.map{|p| p.config.root.to_s}
    dirs.each do |dir|
      if File.directory? File.join(dir,'db/migrate/app')
        target = File.join(dir,'db/migrate/')
        files = Dir["#{target}/*.rb"]
        unless files.empty?
          FileUtils.rm files
          puts "removed #{files.size} migrations from #{target}"
        end

        files = Dir["#{target}/app/*.rb"]
        unless files.empty?
          FileUtils.cp files, target
          puts "copied #{files.size} migrations back to #{target}"
        end
        FileUtils.rm_rf "#{target}/app"
      end
    end
  end
end