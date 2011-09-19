require 'spec_helper'

describe FinancialTxnAccount do
  it "can be instantiated" do
    FinancialTxnAccount.new.should be_an_instance_of(FinancialTxnAccount)
  end

  it "can be saved successfully" do
    FinancialTxnAccount.create().should be_persisted
  end
end