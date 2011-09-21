require 'spec_helper'

describe ChargeLinePaymentTxn do
  it "can be instantiated" do
    ChargeLinePaymentTxn.new.should be_an_instance_of(ChargeLinePaymentTxn)
  end

  it "can be saved successfully" do
    ChargeLinePaymentTxn.create().should be_persisted
  end
end
