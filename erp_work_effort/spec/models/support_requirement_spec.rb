require 'spec_helper'

describe SupportRequirement do
  it "can be instantiated" do
    SupportRequirement.new.should be_an_instance_of(SupportRequirement)
  end

  it "can be saved successfully" do
    SupportRequirement.create().should be_persisted
  end
end