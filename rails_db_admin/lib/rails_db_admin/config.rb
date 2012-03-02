module RailsDbAdmin
  module Config
    class << self
      attr_accessor :query_location

      def init!
        @defaults = {
          :@query_location => File.join('lib', 'rails_db_admin', 'queries')
        }
      end

      def reset!
        @defaults.each do |k,v|
          instance_variable_set(k,v)
        end
      end

      def configure(&blk)
        @configure_blk = blk
      end

      def configure!
        @configure_blk.call(self) if @configure_blk
      end
    end
    init!
    reset!
  end
end
