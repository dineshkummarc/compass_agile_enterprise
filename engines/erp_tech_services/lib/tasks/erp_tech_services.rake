namespace :erp_tech_services do

  namespace :file_support do

    task :sync_storage, [:storage] => :environment do |t,args|
      file_support = TechServices::FileSupport::Base.new(:storage => args.storage.to_sym)

      #sync shared
      file_support.sync('images/', CompassAeInstance.first)
      
      #sync websites
      Website.all.each do |website|
        file_support.sync('/', website)
      end
      
      #sync templates

    end

  end

end

