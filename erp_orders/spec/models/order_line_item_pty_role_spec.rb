require 'spec_helper'

describe OrderLineItemPtyRole do
  it "can be instantiated" do
    OrderLineItemPtyRole.new.should be_an_instance_of(OrderLineItemPtyRole)
  end

  it "can be saved successfully" do
    OrderLineItemPtyRole.create().should be_persisted
  end
end


