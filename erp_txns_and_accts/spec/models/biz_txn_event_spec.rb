require 'spec_helper'

describe BizTxnEvent do
  it "can be instantiated" do
    BizTxnEvent.new.should be_an_instance_of(BizTxnEvent)
  end

  it "can be saved successfully" do
    BizTxnEvent.create().should be_persisted
  end
end