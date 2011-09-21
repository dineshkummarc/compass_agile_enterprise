require 'spec_helper'

describe Payment do
  it "can be instantiated" do
    Payment.new.should be_an_instance_of(Payment)
  end

  it "can be saved successfully" do
    Payment.create().should be_persisted
  end
end