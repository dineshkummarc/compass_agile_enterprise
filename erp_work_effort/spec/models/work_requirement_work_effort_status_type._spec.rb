require 'spec_helper'

describe WorkRequirementWorkEffortStatusType do
  it "can be instantiated" do
    WorkRequirementWorkEffortStatusType.new.should be_an_instance_of(WorkRequirementWorkEffortStatusType)
  end

  it "can be saved successfully" do
    WorkRequirementWorkEffortStatusType.create().should be_persisted
  end
end