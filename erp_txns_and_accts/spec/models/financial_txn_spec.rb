require 'spec_helper'

describe FinancialTxn do
  it "can be instantiated" do
    FinancialTxn.new.should be_an_instance_of(FinancialTxn)
  end

  it "can be saved successfully" do
    FinancialTxn.create().should be_persisted
  end
end