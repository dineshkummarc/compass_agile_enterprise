require 'spec_helper'

describe BizTxnStatus do
  it "can be instantiated" do
    BizTxnStatus.new.should be_an_instance_of(BizTxnStatus)
  end

  it "can be saved successfully" do
    BizTxnStatus.create().should be_persisted
  end
end
