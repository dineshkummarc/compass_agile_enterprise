require 'spec_helper'

describe ContactPurpose do
  it "can be instantiated" do
    ContactPurpose.new.should be_an_instance_of(ContactPurpose)
  end

  it "can be saved successfully" do
    ContactPurpose.create.should be_persisted
  end
  
end