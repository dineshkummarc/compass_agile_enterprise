require 'spec_helper'

describe ChargeLine do
  it "can be instantiated" do
    ChargeLine.new.should be_an_instance_of(ChargeLine)
  end

  it "can be saved successfully" do
    ChargeLine.create().should be_persisted
  end
end
