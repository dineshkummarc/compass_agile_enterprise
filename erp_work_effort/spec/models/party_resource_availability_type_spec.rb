require 'spec_helper'

describe PartyResourceAvailabilityType do
  it "can be instantiated" do
    PartyResourceAvailabilityType.new.should be_an_instance_of(PartyResourceAvailabilityType)
  end

  it "can be saved successfully" do
    PartyResourceAvailabilityType.create().should be_persisted
  end
end