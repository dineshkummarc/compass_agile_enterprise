namespace :erp_tech_svcs do

  namespace :file_support do

    desc "Sync storage between database and storage location ie (s3 or file system), taskes storage option"
    task :sync_storage, [:storage] => :environment do |t,args|
      file_support = ErpTechSvcs::FileSupport::Base.new(:storage => args.storage.to_sym)

      #sync shared
      puts "Syncing Shared Assets..."
      file_support.sync(File.join(file_support.root, '/images'), CompassAeInstance.first)
      file_support.sync(File.join(file_support.root, '/files'), CompassAeInstance.first)
      puts "Complete"

      #sync websites
      puts "Syncing Websites..."
      Website.all.each do |website|
        file_support.sync(File.join(file_support.root, "/sites/site-#{website.id}/images"), website)
        file_support.sync(File.join(file_support.root, "/sites/site-#{website.id}/files"), website)
      end
      puts "Complete"
      
      #sync themes
      puts "Syncing Themes..."
      Theme.all.each do |theme|
        file_support.sync(File.join(file_support.root, theme.url), theme)
      end
      puts "Complete"
    end

  end

  namespace :application do

    task :install do

    end

  end

end

