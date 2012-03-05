require 'erp_dev_svcs/commands/helper'

module ErpDevSvcs
  module Commands
    class Git

      def self.execute
        new()
      end

      def initialize
        ErpDevSvcs::Commands::Helper.exec_in_dirs do
          git_result = %x[git #{ARGV[0]}]
          puts git_result
        end
      end
    end
  end
end
