require 'spec_helper'

describe PricingPlanComponent do
  it "can be instantiated" do
    PricingPlanComponent.new.should be_an_instance_of(PricingPlanComponent)
  end

  it "can be saved successfully" do
    PricingPlanComponent.create().should be_persisted
  end
end