require 'spec_helper'

describe WorkEffortStatus do
  it "can be instantiated" do
    WorkEffortStatus.new.should be_an_instance_of(WorkEffortStatus)
  end

  it "can be saved successfully" do
    WorkEffortStatus.create().should be_persisted
  end
end