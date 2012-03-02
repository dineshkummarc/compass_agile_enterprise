require 'spec_helper'

describe AgreementItem do
  it "can be instantiated" do
    AgreementItem.new.should be_an_instance_of(AgreementItem)
  end

  it "can be saved successfully" do
    AgreementItem.create().should be_persisted
  end
end
