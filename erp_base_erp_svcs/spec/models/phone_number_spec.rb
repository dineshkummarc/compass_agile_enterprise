require 'spec_helper'

describe PhoneNumber do
  it "can be instantiated" do
    PhoneNumber.new.should be_an_instance_of(PhoneNumber)
  end

  it "can be saved successfully" do
    PhoneNumber.create.should be_persisted
  end
  
end