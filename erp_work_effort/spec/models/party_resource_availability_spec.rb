require 'spec_helper'

describe PartyResourceAvailability do
  it "can be instantiated" do
    PartyResourceAvailability.new.should be_an_instance_of(PartyResourceAvailability)
  end

  it "can be saved successfully" do
    PartyResourceAvailability.create().should be_persisted
  end
end