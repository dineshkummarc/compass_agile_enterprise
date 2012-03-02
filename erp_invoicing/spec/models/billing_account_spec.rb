require 'spec_helper'

describe BillingAccount do

  describe 'without invoices and do not calculate' do

    before(:all) do
      @primary_role_type = BizTxnAcctPtyRtype.find_by_internal_identifier('primary') || BizTxnAcctPtyRtype.create(:description => 'Primary Account Holder', :internal_identifier => 'primary')
      @customer = Individual.create(
        :current_last_name => 'Doe',
        :current_first_name => 'John',
        :mothers_maiden_name => 'William'
      )

      @billing_account = BillingAccount.new
      @billing_account = BillingAccount.create()
      @billing_account.account_number = '123456789B'
      @billing_account.calculate_balance = false
      @billing_account.payment_due = 72.20
      @billing_account.balance = 72.20
      @billing_account.due_date = '2012-02-15'
      @billing_account.balance_date = '2012-01-15'
      @billing_account.billing_date = '2012-01-15'
      @billing_account.add_party_with_role(@customer.party, @primary_role_type)
      @billing_account.save
    end

    it "should get balance from billing account" do
      @billing_account.balance.should eq 72.20
    end
    
    it "should get due_date from financial_txn_acct" do
      @billing_account.due_date.should eq '2012-02-15'.to_date
    end

    it "should get billing_date from billing_account" do
      @billing_account.billing_date.should eq '2012-01-15'.to_date
    end

    it "should get balance_date from financial_txn_acct.balance_date" do
      @billing_account.balance_date.should eq '2012-01-15'.to_date
    end

    it "should get payment_due from financial_txn_acct.payment_due" do
      @billing_account.payment_due.should eq 72.20
    end

    it "should allow to get the outstanding_balance" do
      @billing_account.outstanding_balance.should eq 72.20
    end

    it "should allow to check for an outstanding balance" do
      @billing_account.has_outstanding_balance?.should eq true
    end

    it "should allow you get payment applications by type" do
      @billing_account.get_payment_applications(:pending).count.should eq 0
      @billing_account.get_payment_applications(:successful).count.should eq 0
    end

    it "should allow you set payment_due with currency" do
      @billing_account.payment_due = 50.25, Currency.usd
      @billing_account.payment_due.should eq 50.25
    end

    it "should allow you set balance with currency" do
      @billing_account.balance = 50.25, Currency.usd
      @billing_account.balance.should eq 50.25
    end

    after(:all) do
      @billing_account.destroy
      @customer.destroy
    end

  end

end
