require 'spec_helper'

describe ValidPricePlanComponent do
  it "can be instantiated" do
    ValidPricePlanComponent.new.should be_an_instance_of(ValidPricePlanComponent)
  end

  it "can be saved successfully" do
    ValidPricePlanComponent.create().should be_persisted
  end
end
