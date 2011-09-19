require 'spec_helper'

describe BizTxnAcctRoot do
  it "can be instantiated" do
    BizTxnAcctRoot.new.should be_an_instance_of(BizTxnAcctRoot)
  end

  it "can be saved successfully" do
    BizTxnAcctRoot.create().should be_persisted
  end
end

