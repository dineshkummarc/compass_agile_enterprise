require 'spec_helper'

describe BizTxnType do
  it "can be instantiated" do
    BizTxnType.new.should be_an_instance_of(BizTxnType)
  end

  it "can be saved successfully" do
    BizTxnType.create().should be_persisted
  end
end

