require 'optparse'
require 'erp_dev_svcs/commands/helper'

module ErpDevSvcs
  module Commands
    class SetupDevEnv

      def self.execute
        new()
      end

      def initialize
        options = {:engines => nil}

        opt_parser = OptionParser.new do |opt|
          opt.banner = "Usage: compass-dev test [OPTIONS]"

          opt.on("-g", "--gems [GEMLIST]", Array,
                 "List of engines to operate on;"\
                 "defaults to all") {|engines| options[:engines] = engines}

          opt.on_tail("-h", "--help", "Show this message") do
            puts opt
            exit
          end
        end

        opt_parser.parse!

        ErpDevSvcs::Commands::Helper.exec_in_engines(options[:engines]) do |engine_name|
          puts "\nOperating on engine #{engine_name}... \n"
          result = %x[bundle update]
          #result = %x[cp Gemfile.example Gemfile]
          puts result
        end
      end

    end
  end
end
