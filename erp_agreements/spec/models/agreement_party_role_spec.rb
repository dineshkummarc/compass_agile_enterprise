require 'spec_helper'

describe AgreementPartyRole do
  it "can be instantiated" do
    AgreementPartyRole.new.should be_an_instance_of(AgreementPartyRole)
  end

  it "can be saved successfully" do
    AgreementPartyRole.create().should be_persisted
  end
end

