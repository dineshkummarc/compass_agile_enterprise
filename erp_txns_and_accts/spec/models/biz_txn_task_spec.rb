require 'spec_helper'

describe BizTxnTask do
  it "can be instantiated" do
    BizTxnTask.new.should be_an_instance_of(BizTxnTask)
  end

  it "can be saved successfully" do
    BizTxnTask.create().should be_persisted
  end
end
