require 'spec_helper'

describe CreditCardAccount do
  it "can be instantiated" do
    CreditCardAccount.new.should be_an_instance_of(CreditCardAccount)
  end

  it "can be saved successfully" do
    CreditCardAccount.create().should be_persisted
  end
end
