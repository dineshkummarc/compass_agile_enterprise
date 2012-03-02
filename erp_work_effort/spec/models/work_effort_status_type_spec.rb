require 'spec_helper'

describe WorkEffortStatusType do
  it "can be instantiated" do
    WorkEffortStatusType.new.should be_an_instance_of(WorkEffortStatusType)
  end

  it "can be saved successfully" do
    WorkEffortStatusType.create().should be_persisted
  end
end