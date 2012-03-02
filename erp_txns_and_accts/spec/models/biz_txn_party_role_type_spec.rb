require 'spec_helper'

describe BizTxnPartyRoleType do
  it "can be instantiated" do
    BizTxnPartyRoleType.new.should be_an_instance_of(BizTxnPartyRoleType)
  end

  it "can be saved successfully" do
    BizTxnPartyRoleType.create().should be_persisted
  end
end