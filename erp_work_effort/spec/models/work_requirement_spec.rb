require 'spec_helper'

describe WorkRequirement do
  it "can be instantiated" do
    WorkRequirement.new.should be_an_instance_of(WorkRequirement)
  end

  it "can be saved successfully" do
    WorkRequirement.create().should be_persisted
  end
end