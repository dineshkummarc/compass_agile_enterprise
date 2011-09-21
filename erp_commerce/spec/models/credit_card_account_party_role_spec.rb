require 'spec_helper'

describe CreditCardAccountPartyRole do
  it "can be instantiated" do
    CreditCardAccountPartyRole.new.should be_an_instance_of(CreditCardAccountPartyRole)
  end

  it "can be saved successfully" do
    CreditCardAccountPartyRole.create().should be_persisted
  end
end
