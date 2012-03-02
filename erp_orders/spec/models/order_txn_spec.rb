require 'spec_helper'

describe OrderTxn do
  it "can be instantiated" do
    OrderTxn.new.should be_an_instance_of(OrderTxn)
  end

  it "can be saved successfully" do
    OrderTxn.create().should be_persisted
  end
end