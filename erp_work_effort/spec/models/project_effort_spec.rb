require 'spec_helper'

describe ProjectEffort do
  it "can be instantiated" do
    ProjectEffort.new.should be_an_instance_of(ProjectEffort)
  end

  it "can be saved successfully" do
    ProjectEffort.create().should be_persisted
  end
end