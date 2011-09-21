require 'spec_helper'

describe OrderLineItemType do
  it "can be instantiated" do
    OrderLineItemType.new.should be_an_instance_of(OrderLineItemType)
  end

  it "can be saved successfully" do
    OrderLineItemType.create().should be_persisted
  end
end



