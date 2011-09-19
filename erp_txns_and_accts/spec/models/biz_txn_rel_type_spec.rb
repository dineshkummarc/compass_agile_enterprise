require 'spec_helper'

describe BizTxnRelType do
  it "can be instantiated" do
    BizTxnRelType.new.should be_an_instance_of(BizTxnRelType)
  end

  it "can be saved successfully" do
    BizTxnRelType.create().should be_persisted
  end
end