require 'spec_helper'

describe AgreementRelationship do
  it "can be instantiated" do
    AgreementRelationship.new.should be_an_instance_of(AgreementRelationship)
  end

  it "can be saved successfully" do
    AgreementRelationship.create().should be_persisted
  end
end
