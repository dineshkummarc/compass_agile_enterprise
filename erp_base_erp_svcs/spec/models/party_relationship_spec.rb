require 'spec_helper'

describe PartyRelationship do
  it "can be instantiated" do
    PartyRelationship.new.should be_an_instance_of(PartyRelationship)
  end

  it "can be saved successfully" do
    PartyRelationship.create.should be_persisted
  end
  
end