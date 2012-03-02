require 'spec_helper'

describe SupportEffort do
  it "can be instantiated" do
    SupportEffort.new.should be_an_instance_of(SupportEffort)
  end

  it "can be saved successfully" do
    SupportEffort.create().should be_persisted
  end
end