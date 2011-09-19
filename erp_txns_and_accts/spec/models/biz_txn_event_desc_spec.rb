require 'spec_helper'

describe BizTxnEventDesc do
  it "can be instantiated" do
    BizTxnEventDesc.new.should be_an_instance_of(BizTxnEventDesc)
  end

  it "can be saved successfully" do
    BizTxnEventDesc.create().should be_persisted
  end
end



