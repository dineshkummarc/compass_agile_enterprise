require 'spec_helper'

describe PriceComponent do
  it "can be instantiated" do
    PriceComponent.new.should be_an_instance_of(PriceComponent)
  end

  it "can be saved successfully" do
    PriceComponent.create().should be_persisted
  end
end