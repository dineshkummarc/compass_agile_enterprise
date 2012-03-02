require 'spec_helper'

describe BizTxnAgreementRole do
  it "can be instantiated" do
    BizTxnAgreementRole.new.should be_an_instance_of(BizTxnAgreementRole)
  end

  it "can be saved successfully" do
    BizTxnAgreementRole.create().should be_persisted
  end
end



