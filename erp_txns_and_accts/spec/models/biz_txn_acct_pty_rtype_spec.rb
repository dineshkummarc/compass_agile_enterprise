require 'spec_helper'

describe BizTxnAcctPtyRtype do
  it "can be instantiated" do
    BizTxnAcctPtyRtype.new.should be_an_instance_of(BizTxnAcctPtyRtype)
  end

  it "can be saved successfully" do
    BizTxnAcctPtyRtype.create().should be_persisted
  end
end