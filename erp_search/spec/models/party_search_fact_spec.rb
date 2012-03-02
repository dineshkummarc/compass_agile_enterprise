require 'spec_helper'

describe PartySearchFact do
  it "can be instantiated" do
    PartySearchFact.new.should be_an_instance_of(PartySearchFact)
  end

  it "can be saved successfully" do
    PartySearchFact.create().should be_persisted
  end
end