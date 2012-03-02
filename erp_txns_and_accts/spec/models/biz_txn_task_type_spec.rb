require 'spec_helper'

describe BizTxnTaskType do
  it "can be instantiated" do
    BizTxnTaskType.new.should be_an_instance_of(BizTxnTaskType)
  end

  it "can be saved successfully" do
    BizTxnTaskType.create().should be_persisted
  end
end
