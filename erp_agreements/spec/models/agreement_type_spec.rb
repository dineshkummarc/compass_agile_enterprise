require 'spec_helper'

describe AgreementType do
  it "can be instantiated" do
    AgreementType.new.should be_an_instance_of(AgreementType)
  end

  it "can be saved successfully" do
    AgreementType.create().should be_persisted
  end
end
