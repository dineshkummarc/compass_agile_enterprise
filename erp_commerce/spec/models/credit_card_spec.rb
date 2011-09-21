require 'spec_helper'

describe CreditCard do
  it "can be instantiated" do
    CreditCard.new.should be_an_instance_of(CreditCard)
  end

  it "can be saved successfully" do
    CreditCard.create().should be_persisted
  end
end