module ErpBaseErpSvcs
  class CompassAE
    class << self
 
    	def banner
        %(
Usage:
  compass_ae new <app_name> [rails_opt]  Creates a new Rails Compass AE Application
    rails_opt:            all the options accepted by the rails command
  
  compass_ae --help|-h             This help screen
        )
    	end
    
    	def run
        if ARGV.first != "new"
          ARGV[0] = "--help"
        end

        command = ARGV.shift
        case command
        when '--help'
          puts self.banner
      	when 'new'
          template_path = File.join(File.dirname(__FILE__), 'rails_template.rb')
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
