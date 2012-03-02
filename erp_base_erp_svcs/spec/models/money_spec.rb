require 'spec_helper'

describe Money do
  it "can be instantiated" do
    Money.new.should be_an_instance_of(Money)
  end

  it "can be saved successfully" do
    Money.create.should be_persisted
  end
  
end