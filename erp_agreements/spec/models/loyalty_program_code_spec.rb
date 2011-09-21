require 'spec_helper'

describe LoyaltyProgramCode do
  it "can be instantiated" do
    LoyaltyProgramCode.new.should be_an_instance_of(LoyaltyProgramCode)
  end

  it "can be saved successfully" do
    LoyaltyProgramCode.create().should be_persisted
  end
end

