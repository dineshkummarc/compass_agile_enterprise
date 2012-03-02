require 'spec_helper'

describe AgreementRelnType do
  it "can be instantiated" do
    AgreementRelnType.new.should be_an_instance_of(AgreementRelnType)
  end

  it "can be saved successfully" do
    AgreementRelnType.create().should be_persisted
  end
end

