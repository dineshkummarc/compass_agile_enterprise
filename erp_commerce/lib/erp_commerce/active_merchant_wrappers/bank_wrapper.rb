module ErpCommerce
  module ActiveMerchantWrappers
    class BankWrapper
      def self.purchase(account_number, routing_number, amount)
        result = {}

        result[:message] = "Payment applied"
        result[:payment] = Payment.create
        result[:payment].authorization_code = '123456789'
        result[:payment].success = true
        #result[:payment].purchase

        result
      end
    end
  end
end