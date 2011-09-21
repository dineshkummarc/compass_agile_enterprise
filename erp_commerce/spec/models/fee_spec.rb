require 'spec_helper'

describe Fee do
  it "can be instantiated" do
    Fee.new.should be_an_instance_of(Fee)
  end

  it "can be saved successfully" do
    Fee.create().should be_persisted
  end
end
