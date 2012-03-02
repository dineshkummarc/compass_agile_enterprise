require 'spec_helper'

describe WorkEffort do
  it "can be instantiated" do
    WorkEffort.new.should be_an_instance_of(WorkEffort)
  end

  it "can be saved successfully" do
    WorkEffort.create().should be_persisted
  end
end