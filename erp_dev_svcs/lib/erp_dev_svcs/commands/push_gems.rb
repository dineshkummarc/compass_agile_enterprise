require 'optparse'
require 'erp_dev_svcs/commands/helper'

module ErpDevSvcs
  module Commands
    class PushGems

      def self.execute
        new()
      end

      def initialize
        options = {}

        optparse = OptionParser.new do|opts|
          opts.banner = "Usage: compass-dev push_gems [options]"

          options[:verbose] = false
          opts.on('-v', '--verbose', 'Output more information') do
            options[:verbose] = true
          end

          options[:ruby_gems] = false
          opts.on('-r', '--ruby_gems', 'push to ruby gems') do
            options[:ruby_gems] = true
          end

          options[:geminabox] = true
          opts.on('-b', '--geminabox', 'push to geminabox') do
            options[:geminabox] = true
            options[:ruby_gems] = false
          end

          opt.on("-g", "--gems [GEMLIST]", Array,
                 "List of engines to operate on;"\
                 "defaults to all") {|engines| options[:engines] = engines}

          opt.on_tail("-h", "--help", "Show this message") do
            puts opt
            exit
          end
        end

        opt_parser.parse!

        ErpDevSvcs::Commands::Helper.exec_in_engines(options[:gems]) do |engine_name|
          gem_file = Dir.glob("*.gem")[0]

          if options[:ruby_gems]
            result = %x[gem push #{gem_file}]
            puts result if options[:verbose]
          end

          if options[:geminabox]
            result = %x[gem inabox #{gem_file}]
            puts result if options[:verbose]
          end
        end

      end
    end
  end
end
