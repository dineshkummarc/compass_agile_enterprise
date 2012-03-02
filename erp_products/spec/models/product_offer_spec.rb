require 'spec_helper'

describe ProductOffer do
  it "can be instantiated" do
    ProductOffer.new.should be_an_instance_of(ProductOffer)
  end

  it "can be saved successfully" do
    ProductOffer.create().should be_persisted
  end
end

