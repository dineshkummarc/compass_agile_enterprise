require 'spec_helper'

describe AgreementItemType do
  it "can be instantiated" do
    AgreementItemType.new.should be_an_instance_of(AgreementItemType)
  end

  it "can be saved successfully" do
    AgreementItemType.create().should be_persisted
  end
end
