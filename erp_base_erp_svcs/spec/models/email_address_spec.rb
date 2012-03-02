require 'spec_helper'

describe EmailAddress do
  it "can be instantiated" do
    EmailAddress.new.should be_an_instance_of(EmailAddress)
  end

  it "can be saved successfully" do
    EmailAddress.create.should be_persisted
  end
  
end