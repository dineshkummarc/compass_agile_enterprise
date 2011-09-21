require 'spec_helper'

describe AgreementRoleType do
  it "can be instantiated" do
    AgreementRoleType.new.should be_an_instance_of(AgreementRoleType)
  end

  it "can be saved successfully" do
    AgreementRoleType.create().should be_persisted
  end
end


