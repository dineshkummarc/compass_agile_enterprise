require 'spec_helper'

describe Price do
  it "can be instantiated" do
    Price.new.should be_an_instance_of(Price)
  end

  it "can be saved successfully" do
    Price.create().should be_persisted
  end
end
