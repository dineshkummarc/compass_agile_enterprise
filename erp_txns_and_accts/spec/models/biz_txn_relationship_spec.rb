require 'spec_helper'

describe BizTxnRelationship do
  it "can be instantiated" do
    BizTxnRelationship.new.should be_an_instance_of(BizTxnRelationship)
  end

  it "can be saved successfully" do
    BizTxnRelationship.create().should be_persisted
  end
end
