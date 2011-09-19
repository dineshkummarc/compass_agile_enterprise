require 'spec_helper'

describe BizTxnAcctType do
  it "can be instantiated" do
    BizTxnAcctType.new.should be_an_instance_of(BizTxnAcctType)
  end

  it "can be saved successfully" do
    BizTxnAcctType.create().should be_persisted
  end
end


