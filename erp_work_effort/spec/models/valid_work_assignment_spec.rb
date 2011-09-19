require 'spec_helper'

describe ValidWorkAssignment do
  it "can be instantiated" do
    ValidWorkAssignment.new.should be_an_instance_of(ValidWorkAssignment)
  end

  it "can be saved successfully" do
    ValidWorkAssignment.create().should be_persisted
  end
end