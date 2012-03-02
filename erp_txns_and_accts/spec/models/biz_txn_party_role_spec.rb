require 'spec_helper'

describe BizTxnPartyRole do
  it "can be instantiated" do
    BizTxnPartyRole.new.should be_an_instance_of(BizTxnPartyRole)
  end

  it "can be saved successfully" do
    BizTxnPartyRole.create().should be_persisted
  end
end