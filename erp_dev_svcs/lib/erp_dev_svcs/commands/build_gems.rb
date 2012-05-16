require 'optparse'
require 'erp_dev_svcs/commands/helper'

module ErpDevSvcs
  module Commands
    class BuildGems

      def self.execute
        new()
      end

      def initialize
        options = {:install => false,
          :gems => nil}

        opt_parser = OptionParser.new do |opt|
          opt.banner = "Usage: compass-util build_gems [OPTIONS]"

          opt.on("-g", "--gems [GEMLIST]", Array,
            "List of gems to build; defaults to all") {|gem| options[:gems] = gem}

          opt.on("-i", "--install",nil,
            "Install the gem locally after it's built") do |x|
            options[:install] = true
          end

          opt.on("-n", "--no-docs",nil,
            "Use --no-ri --no-rdoc") do |x|
            options[:no_docs] = true
          end
          
          opt.on_tail("-h", "--help", "Show this message") do
            puts opt
            exit
          end
        end

        opt_parser.parse!

        ErpDevSvcs::Commands::Helper.exec_in_engines(options[:gems]) do |engine_name|
          old_gem_files = Dir.glob("*.gem")
          old_gem_files.each {|x| File.delete(x); puts "\nDeleting old gem: #{x}"}

          puts "Starting build of #{engine_name}"
          build_result = %x[gem build #{engine_name}.gemspec]
          puts build_result

          if options[:install]
            gem_file = Dir.glob("*.gem")
            puts "Installing #{gem_file[0]}..."
            install_result = if options[:no_docs]
              %x[gem install #{gem_file[0]} --no-ri --no-rdoc]
            else
              %x[gem install #{gem_file[0]}]
            end
            puts install_result
          end
          puts "\n"
        end
      end

    end
  end
end
