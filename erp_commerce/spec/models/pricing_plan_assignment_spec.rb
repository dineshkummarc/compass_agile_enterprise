require 'spec_helper'

describe PricingPlanAssignment do
  it "can be instantiated" do
    PricingPlanAssignment.new.should be_an_instance_of(PricingPlanAssignment)
  end

  it "can be saved successfully" do
    PricingPlanAssignment.create().should be_persisted
  end
end
