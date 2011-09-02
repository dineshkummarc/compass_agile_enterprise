require 'spec_helper'

describe Organizer do
  it "can be instantiated" do
    Organizer.new.should be_an_instance_of(Organizer)
  end

  it "can be saved successfully" do
    Organizer.create().should be_persisted
  end
end