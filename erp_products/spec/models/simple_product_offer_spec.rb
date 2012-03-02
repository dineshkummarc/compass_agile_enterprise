require 'spec_helper'

describe SimpleProductOffer do
  it "can be instantiated" do
    SimpleProductOffer.new.should be_an_instance_of(SimpleProductOffer)
  end

  it "can be saved successfully" do
    SimpleProductOffer.create().should be_persisted
  end
end



