require 'spec_helper'

describe PaymentGateway do
  it "can be instantiated" do
    PaymentGateway.new.should be_an_instance_of(PaymentGateway)
  end

  it "can be saved successfully" do
    PaymentGateway.create().should be_persisted
  end
end
