require 'optparse'
require 'erp_dev_svcs/commands/helper'

module ErpDevSvcs
  module Commands
    class UninstallGems

      def self.execute
        new()
      end

      def initialize
        options = {:install => false, :gems => nil}

        opt_parser = OptionParser.new do |opt|
          opt.banner = "Usage: compass-util uninstall_gems"
          
          opt.on("-g", "--gems [GEMLIST]", Array,
            "List of gems to uninstall; defaults to all") {|gem| options[:gems] = gem}
          
          opt.on_tail("-h", "--help", "Show this message") do
            puts opt
            exit
          end
        end

        opt_parser.parse!

        ErpDevSvcs::Commands::Helper.exec_in_engines(options[:gems]) do |engine_name|
          puts "Uninstalling gem #{engine_name}"
          result = %x[gem uninstall #{engine_name}]
          puts result
          puts "\n"
        end
      end

    end
  end
end
