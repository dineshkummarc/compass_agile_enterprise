require 'spec_helper'

describe WorkEffortAssignment do
  it "can be instantiated" do
    WorkEffortAssignment.new.should be_an_instance_of(WorkEffortAssignment)
  end

  it "can be saved successfully" do
    party = Party.new(:description => 'Test Party')
    work_effort = WorkEffort.new
    WorkEffortAssignment.create(:assigned_to => party, :assigned_by => party, :work_effort => work_effort).should be_persisted
  end
end