module CompassAeStarterKit
  RAILS_MAJOR = 3
  RAILS_MINOR = 1
  RAILS_TINY  = '*'
  class CompassAE
    class << self
      def banner
        %(
Usage:
  compass_ae new <app_name> [rails_opt]  Creates a new Rails Compass AE Application
    rails_opt:            all the options accepted by the rails command
  
  compass_ae dev <app_name> [rails_opt]  Creates a new Rails Compass AE Application and clones our repository and points the Compass AE gems to it
    rails_opt:            all the options accepted by the rails command
    
  compass_ae --help|-h    This help screen
        )
    	end
    
    	def run
        #Get rails version
        major, minor, tiny = `rails -v`.gsub!('Rails ', '').gsub!("\n",'').split('.').collect{|version| version.to_i}
        if version_allowed?(RAILS_MAJOR, major) and version_allowed?(RAILS_MINOR, minor) and version_allowed?(RAILS_TINY, tiny)
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
        else
          puts "Installed Rails version is not compatible #{[major, minor, tiny].compact.join('.')}, please install #{[RAILS_MAJOR, RAILS_MINOR, RAILS_TINY].compact.join('.')}"
        end

      end

      def version_allowed?(allowed_version, version)
        result = true
        unless(allowed_version == '*')
          result = (allowed_version == version)
        end
        result
      end

    end#self
  end#CompassAE
end#ErpBaseErpSvcs
