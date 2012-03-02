require 'spec_helper'

describe BizAcctTxnTask do
  it "can be instantiated" do
    BizAcctTxnTask.new.should be_an_instance_of(BizAcctTxnTask)
  end

  it "can be saved successfully" do
    BizAcctTxnTask.create().should be_persisted
  end
end
