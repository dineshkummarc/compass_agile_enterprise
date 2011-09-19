require 'spec_helper'

describe BizTxnAcctStatus do
  it "can be instantiated" do
    BizTxnAcctStatus.new.should be_an_instance_of(BizTxnAcctStatus)
  end

  it "can be saved successfully" do
    BizTxnAcctStatus.create().should be_persisted
  end
end


