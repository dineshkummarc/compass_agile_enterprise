require "activerecord"

namespace :compass do
  namespace :backup do
  	
  	BACKUP_DIR = '/backup/postgres'
  	SU_POSTGRES = true 
  	
  	desc 'backup all postgres databases'
    task :postgres => :environment do
      create_directory(BACKUP_DIR)

      databases = ActiveRecord::Base.connection.select_values('SELECT datname FROM pg_database;')

      puts red("Backing up ALL postgres databases via pg_dump")
      databases.each do |db|
        puts "Dumping #{db} to #{BACKUP_DIR}"
        cmd = "pg_dump #{db} > #{BACKUP_DIR}/#{db}_#{Time.now.strftime("%Y-%m-%d_%Hh%Mm%Ss")}.pgsl"
        cmd = "sudo su postgres -c \"#{cmd}\"" if SU_POSTGRES
        execute_command(cmd)
      end
      
      puts "\nBackup Complete."
    end

    def create_directory(foldername)
      FileUtils.mkdir_p(foldername) unless File.directory?(foldername)
    end

    def green(text); 
      colorize(text, "\033[32m")
    end

    def red(text)
      colorize(text, "\033[31m")
    end

    def colorize(text, color_code)
      "#{color_code}#{text}\033[0m"
    end

    def execute_command(cmd)
      puts green(cmd)
      system cmd
    end    
  end
end
