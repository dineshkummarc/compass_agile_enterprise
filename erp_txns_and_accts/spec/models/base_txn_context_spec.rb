require 'spec_helper'

describe BaseTxnContext do
  it "can be instantiated" do
    BaseTxnContext.new.should be_an_instance_of(BaseTxnContext)
  end

  it "can be saved successfully" do
    BaseTxnContext.create().should be_persisted
  end
end
