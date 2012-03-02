require 'spec_helper'

describe BizTxnAcctPartyRole do
  it "can be instantiated" do
    BizTxnAcctPartyRole.new.should be_an_instance_of(BizTxnAcctPartyRole)
  end

  it "can be saved successfully" do
    BizTxnAcctPartyRole.create().should be_persisted
  end
end
