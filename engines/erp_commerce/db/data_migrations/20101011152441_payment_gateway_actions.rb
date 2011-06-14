class PaymentGatewayActions
  
  def self.up
    PaymentGatewayAction.create(
      :internal_identifier => 'capture',
      :description => 'capture'
    )

    PaymentGatewayAction.create(
      :internal_identifier => 'authorize',
      :description => 'Authorize'
    )

    PaymentGatewayAction.create(
      :internal_identifier => 'full_reverse_of_authorization',
      :description => 'Full Reverse Of Authorization'
    )
  end
  
  def self.down
    ['sale','void_sale','authorize'].each do |iid|
      type = PaymentGatewayAction.find_by_internal_identifier(iid)
      type.destroy unless type.nil?
    end
  end

end
