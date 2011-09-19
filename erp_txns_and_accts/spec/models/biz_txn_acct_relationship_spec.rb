require 'spec_helper'

describe BizTxnAcctRelationship do
  it "can be instantiated" do
    BizTxnAcctRelationship.new.should be_an_instance_of(BizTxnAcctRelationship)
  end

  it "can be saved successfully" do
    BizTxnAcctRelationship.create().should be_persisted
  end
end
