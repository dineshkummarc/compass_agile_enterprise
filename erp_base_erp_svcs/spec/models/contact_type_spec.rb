require 'spec_helper'

describe ContactType do
  it "can be instantiated" do
    ContactType.new.should be_an_instance_of(ContactType)
  end

  it "can be saved successfully" do
    ContactType.create.should be_persisted
  end
  
end