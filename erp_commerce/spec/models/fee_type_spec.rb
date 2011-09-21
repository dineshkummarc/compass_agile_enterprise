require 'spec_helper'

describe FeeType do
  it "can be instantiated" do
    FeeType.new.should be_an_instance_of(FeeType)
  end

  it "can be saved successfully" do
    FeeType.create().should be_persisted
  end
end
