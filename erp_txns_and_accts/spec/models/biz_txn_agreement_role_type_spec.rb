require 'spec_helper'

describe BizTxnAgreementRoleType do
  it "can be instantiated" do
    BizTxnAgreementRoleType.new.should be_an_instance_of(BizTxnAgreementRoleType)
  end

  it "can be saved successfully" do
    BizTxnAgreementRoleType.create().should be_persisted
  end
end



