require 'spec_helper'

describe OrderTxnType do
  it "can be instantiated" do
    OrderTxnType.new.should be_an_instance_of(OrderTxnType)
  end

  it "can be saved successfully" do
    OrderTxnType.create().should be_persisted
  end
end