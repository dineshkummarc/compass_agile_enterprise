require 'spec_helper'

describe BizTxnAcctRelType do
  it "can be instantiated" do
    BizTxnAcctRelType.new.should be_an_instance_of(BizTxnAcctRelType)
  end

  it "can be saved successfully" do
    BizTxnAcctRelType.create().should be_persisted
  end
end