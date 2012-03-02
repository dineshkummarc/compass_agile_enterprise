require 'spec_helper'

describe PartyRole do
  it "can be instantiated" do
    PartyRole.new.should be_an_instance_of(PartyRole)
  end

  it "can be saved successfully" do
    PartyRole.create.should be_persisted
  end
  
end