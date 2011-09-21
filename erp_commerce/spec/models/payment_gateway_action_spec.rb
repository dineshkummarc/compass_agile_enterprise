require 'spec_helper'

describe PaymentGatewayAction do
  it "can be instantiated" do
    PaymentGatewayAction.new.should be_an_instance_of(PaymentGatewayAction)
  end

  it "can be saved successfully" do
    PaymentGatewayAction.create().should be_persisted
  end
end
