class PaymentGateway < ActiveRecord::Base
    belongs_to :payment_gateway_action
    belongs_to :payment
end
