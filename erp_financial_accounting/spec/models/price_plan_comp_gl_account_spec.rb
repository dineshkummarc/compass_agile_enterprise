require 'spec_helper'

describe PricePlanCompGlAccount do
  it "can be instantiated" do
    PricePlanCompGlAccount.new.should be_an_instance_of(PricePlanCompGlAccount)
  end

  it "can be saved successfully" do
    PricePlanCompGlAccount.create().should be_persisted
  end
end

