require 'spec_helper'

describe BizTxnAcctStatusType do
  it "can be instantiated" do
    BizTxnAcctStatusType.new.should be_an_instance_of(BizTxnAcctStatusType)
  end

  it "can be saved successfully" do
    BizTxnAcctStatusType.create().should be_persisted
  end
end


