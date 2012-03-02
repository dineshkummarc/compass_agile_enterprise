module CompassAeStarterKit
  class CompassAE
    class << self
 
    	def banner
        %(
Usage:
  compass_ae new <app_name> [rails_opt]  Creates a new Rails Compass AE Application
    rails_opt:            all the options accepted by the rails command
  
  compass_ae dev <app_name> [rails_opt]  Creates a new Rails Compass AE Application with the gems pointing to our Git repository
    rails_opt:            all the options accepted by the rails command
    
  compass_ae --help|-h             This help screen
        )
    	end
    
    	def run
        template_path = File.join(File.dirname(__FILE__), '../templates/default_template.rb')
        
        if ARGV.first != "new" and ARGV.first != "dev"
          ARGV[0] = "--help"
        end
        
        if ARGV.first == "dev"
          template_path = File.join(File.dirname(__FILE__), '../templates/development_template.rb')
          ARGV[0] = "new"
        end

        command = ARGV.shift
        case command
        when '--help'
          puts self.banner
      	when 'new'
          app_name = ARGV.shift
          raise "The application name is missing!" if app_name.nil?
          puts 'Generating Rails infrastructure...'
          system "rails new #{app_name} #{ARGV * ' '} -m #{template_path}"
          Dir.chdir app_name
          system "rake db:migrate"
          system "rake db:migrate_data"
        end
      end

    end#self
  end#CompassAE
end#ErpBaseErpSvcs
