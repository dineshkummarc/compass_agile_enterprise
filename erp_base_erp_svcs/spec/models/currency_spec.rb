require 'spec_helper'

describe Currency do
  it "can be instantiated" do
    Currency.new.should be_an_instance_of(Currency)
  end

  it "can be saved successfully" do
    Currency.create.should be_persisted
  end
  
end