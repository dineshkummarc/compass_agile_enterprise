require 'spec_helper'

describe Party do
  it "can be instantiated" do
    Party.new.should be_an_instance_of(Party)
  end

  it "can be saved successfully" do
    Party.create.should be_persisted
  end

end