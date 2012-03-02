require 'spec_helper'

describe ProdAvailabilityStatusType do
  it "can be instantiated" do
    ProdAvailabilityStatusType.new.should be_an_instance_of(ProdAvailabilityStatusType)
  end

  it "can be saved successfully" do
    ProdAvailabilityStatusType.create().should be_persisted
  end
end