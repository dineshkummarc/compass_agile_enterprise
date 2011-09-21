require 'spec_helper'

describe CreditCardAccountPurpose do
  it "can be instantiated" do
    CreditCardAccountPurpose.new.should be_an_instance_of(CreditCardAccountPurpose)
  end

  it "can be saved successfully" do
    CreditCardAccountPurpose.create().should be_persisted
  end
end
