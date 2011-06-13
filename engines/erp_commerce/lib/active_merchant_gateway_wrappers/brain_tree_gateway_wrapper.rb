require 'active_merchant'

module ActiveMerchantGatewayWrappers
  class BrainTreeGatewayWrapper

    def self.purchase(credit_card_hash, gateway_options={})
      result = {}
      
      #test
      ActiveMerchant::Billing::Base.mode = :test
      
      #setup gateway
      gateway = ActiveMerchant::Billing::BraintreeGateway.new(gateway_options)

      #set credit card info
      credit_card = ActiveMerchant::Billing::CreditCard.new({
          :first_name         => credit_card_hash[:first_name],
          :last_name          => credit_card_hash[:last_name],
          :number             => credit_card_hash[:number],
          :month              => credit_card_hash[:exp_month],
          :year               => credit_card_hash[:exp_year],
          :verification_value => credit_card_hash[:cvvs],
          :type               => ActiveMerchantGatewayWrappers::CreditCardValidation.get_card_type(credit_card_hash[:number])
        })

      if credit_card.valid?
        cents = (credit_card_hash[:charge_amount].to_f * 100)
        response = gateway.purchase(cents, credit_card)

        if response.success?
          result[:message] = response.message
          result[:payment] = Payment.new
          result[:payment].authorization_code = response.authorization
          result[:payment].success = true
          result[:payment].purchase
        else
          result[:message] = response.message
          result[:payment] = Payment.new
          result[:payment].success = false
          result[:payment].decline
        end

        gateway = PaymentGateway.create(
          :response => response.message,
          :payment_gateway_action => PaymentGatewayAction.find_by_internal_identifier('authorize')
        )

        result[:payment].payment_gateways << gateway
        result[:payment].save
      else
        result[:message] = "<ul>"
        credit_card.errors.full_messages.each do |current_notice_msg|
          result[:message] << "<li>"
          result[:message] << current_notice_msg
          result[:message] << "</li>"
        end
        result[:message] << "<ul>"
      end

      result
    end

  end
end
