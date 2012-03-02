require 'spec_helper'

describe ValidWorkAssignmentAttribute do
  it "can be instantiated" do
    ValidWorkAssignmentAttribute.new.should be_an_instance_of(ValidWorkAssignmentAttribute)
  end

  it "can be saved successfully" do
    ValidWorkAssignmentAttribute.create().should be_persisted
  end
end