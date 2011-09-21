require 'spec_helper'

describe OrderLineItem do
  it "can be instantiated" do
    OrderLineItem.new.should be_an_instance_of(OrderLineItem)
  end

  it "can be saved successfully" do
    OrderLineItem.create().should be_persisted
  end
end

