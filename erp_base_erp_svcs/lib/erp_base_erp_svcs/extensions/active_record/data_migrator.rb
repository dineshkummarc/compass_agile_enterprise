module RussellEdge
  class DataMigrator

    class << self
      def prepare_upgrade_migrations
        dirs = Rails::Application::Railties.engines.map{|p| p.config.root.to_s}
        dirs.each do |dir|
          if File.directory? File.join(dir,'db/data_migrations/upgrade')
            target = File.join(dir,'db/data_migrations/')
            files = Dir["#{target}*.rb"]
            unless files.empty?
              FileUtils.mkdir_p "#{target}app/"
              FileUtils.cp files, "#{target}app/"
              puts "copied #{files.size} upgrade data migrations to #{target}app"
            end

            files = Dir["#{File.join(dir,'db/data_migrations/upgrade')}/*.rb"]
            FileUtils.cp files, File.join(dir,'db/data_migrations/')
          end
        end
      end

      def cleanup_upgrade_migrations
        dirs = Rails::Application::Railties.engines.map{|p| p.config.root.to_s}
        dirs.each do |dir|
          if File.directory? File.join(dir,'db/data_migrations/app')
            target = File.join(dir,'db/data_migrations/')
            files = Dir["#{target}/*.rb"]
            unless files.empty?
              FileUtils.rm files
              puts "removed #{files.size} data migrations from #{target}"
            end

            files = Dir["#{target}/app/*.rb"]
            unless files.empty?
              FileUtils.cp files, target
              puts "copied #{files.size} data migrations back to #{target}"
            end
            FileUtils.rm_rf "#{target}/app"
          end
        end
      end
    end

  end#DataMigrator
end#RussellEdge