require 'spec_helper'

describe PricingPlan do
  it "can be instantiated" do
    PricingPlan.new.should be_an_instance_of(PricingPlan)
  end

  it "can be saved successfully" do
    PricingPlan.create().should be_persisted
  end
end