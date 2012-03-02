require 'erp_dev_svcs/commands/helper'

module ErpDevSvcs
  module Commands
    class Git

      def self.execute
        new()
      end

      def initialize
        ErpDevSvcs::Commands::Helper.find_rails_root!

        Dir.chdir("lib/compass")
        root_dir = Dir.pwd

        Dir.foreach(".") do |dir_item|
          next if dir_item == '..' || dir_item == '.'

          if File.directory?(dir_item)
            Dir.chdir(dir_item)

            puts "\nChanging to #{dir_item}...\n"
            git_result = %x[git #{ARGV[0]}]
            puts git_result
            Dir.chdir(root_dir)
          end
        end
      end

    end
  end
end
