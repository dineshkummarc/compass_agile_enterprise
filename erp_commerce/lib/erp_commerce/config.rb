module ErpCommerce
  module Config
    class << self
      attr_accessor :encryption_key, :active_merchange_gateway_wrapper

      def init!
        @defaults = {
          :@encryption_key => 'my_secret_code',
          :@active_merchange_gateway_wrapper => ErpCommerce::ActiveMerchantWrappers::BrainTreeGatewayWrapper
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