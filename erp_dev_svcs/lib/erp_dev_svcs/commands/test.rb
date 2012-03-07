require 'optparse'
require 'erp_dev_svcs/commands/helper'

module ErpDevSvcs
  module Commands
    class Test

      def self.execute
        new()
      end

      def initialize
        options = {:gems => nil}

        opt_parser = OptionParser.new do |opt|
          opt.banner = "Usage: compass-util test [OPTIONS]"

          opt.on("-g", "--gems [GEMLIST]", Array,
                 "List of engines to test;"\
                 "defaults to all") {|gem| options[:gems] = gem}

          opt.on_tail("-h", "--help", "Show this message") do
            puts opt
            exit
          end
        end

        opt_parser.parse!
        ErpDevSvcs::Commands::Helper.exec_in_engines(options[:gems]) do |engine_name|
          puts "\nRunning #{engine_name}'s test suite...  \n"
          result = %x[bundle exec rspec --tty --color spec]
          puts result
        end
      end

    end
  end
end
