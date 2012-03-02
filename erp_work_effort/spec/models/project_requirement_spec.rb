require 'spec_helper'

describe ProjectRequirement do
  it "can be instantiated" do
    ProjectRequirement.new.should be_an_instance_of(ProjectRequirement)
  end

  it "can be saved successfully" do
    ProjectRequirement.create().should be_persisted
  end
end