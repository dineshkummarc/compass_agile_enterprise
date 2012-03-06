require 'optparse'
require 'erp_dev_svcs/commands/helper'

module ErpDevSvcs
  module Commands
    class SetupDevEnv

      def self.execute
        new()
      end

      def initialize
        options = {:engines => nil,
                   :create_gemfiles => false,
                   :bundle => false}

        opt_parser = OptionParser.new do |opt|
          opt.banner = "Usage: compass-dev test [OPTIONS]"

          opt.on("-g", "--gems [GEMLIST]", Array,
                 "List of engines to operate on;"\
                 "defaults to all") {|engines| options[:engines] = engines}
          opt.on("-c", "--create-gemfiles", nil,
                 "Create Gemfiles in engines from Gemfile.example") do |x|
                   options[:create_gemfiles] = true
                 end
          opt.on("-b", "--bundle-engines", nil,
                 "Run 'bundle install' in engines") {|x| options[:bundle] = true}
          opt.on_tail("-h", "--help", "Show this message") do
            puts opt
            exit
          end
        end

        opt_parser.parse!

        if options[:create_gemfiles] == false && options[:bundle] == false
          puts opt_parser
          exit
        end

        ErpDevSvcs::Commands::Helper.exec_in_engines(options[:engines]) do |engine_name|
          puts "\nOperating on engine #{engine_name}... \n"
          puts %x[cp Gemfile.example Gemfile] if options[:create_gemfiles] == true
          puts %x[bundle update] if options[:bundle] == true
          #result = %x[cp Gemfile.example Gemfile]
          #puts result
        end
      end

    end
  end
end
