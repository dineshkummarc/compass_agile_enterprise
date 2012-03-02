module ErpBaseErpSvcs
  module Config
    class << self
      attr_accessor :compass_ae_engines

      def init!
        @defaults = {
          :@compass_ae_engines => []
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
