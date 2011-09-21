require 'spec_helper'

describe PriceComponentType do
  it "can be instantiated" do
    PriceComponentType.new.should be_an_instance_of(PriceComponentType)
  end

  it "can be saved successfully" do
    PriceComponentType.create().should be_persisted
  end
end
