module ErpBaseErpSvcs
  module Command
    extend self
    
    def banner
      %(
Usage:
    compass_ae new <app_name> [setup_opt] [rails_opt]  Creates a new Rails Compass AE Application
        setup_opt:
            --skip-setup      generate only the rails infrastructure
        rails_opt:            all the options accepted by the rails command

    erp --help|-h             This help screen)
    end
    
    def run
      command = ARGV.shift
      case command
      when nil
        raise "The command is missing!"
      when 'skip'
        app_name = ARGV.shift
        raise "The application name is missing!" if app_name.nil?
        puts 'Generating Rails infrastructure...'
        system "rails new #{app_name} #{ARGV * ' '}"
      when 'new'
        template_path = File.join(File.dirname(__FILE__), 'rails_template.rb')
        app_name = ARGV.shift
        raise "The application name is missing!" if app_name.nil?
        puts 'Generating Rails infrastructure...'
        system "rails new #{app_name} #{ARGV * ' '} -m #{template_path}"
      end
    
    end
    
  end
end