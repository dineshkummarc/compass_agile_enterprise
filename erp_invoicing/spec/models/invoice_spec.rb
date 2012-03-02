require 'spec_helper'

describe Invoice do

  before(:all) do
    @payor_role_type = RoleType.find_by_internal_identifier('payor') || RoleType.create(:description => 'Payor', :internal_identifier => 'payor')
    @customer = Individual.create(
      :current_last_name => 'Doe',
      :current_first_name => 'John',
      :mothers_maiden_name => 'William'
    )
    @invoice = Invoice.create(:invoice_number => 'I123456789A',
      :invoice_date => '2012-01-15',
      :due_date => '2012-05-15',
      :description => 'Invoice 2011-12-01 - 2011-12-31')
    @invoice_item = InvoiceItem.create(:amount => 29.99, :quantity => 25, :item_description => '7619851 BICEP II MAGNUM 2X2.5GA')
    @invoice.items << @invoice_item
    @invoice.save
  end

  it "should allow you add parties by role_Type" do
    @invoice.add_party_with_role_type(@customer.party, @payor_role_type)
    parties = @invoice.find_parties_by_role_type(@payor_role_type)
    parties.count.should eq 1
    parties.first.id.should eq @customer.party.id
  end

  it "should allow you to transactions" do
    transactions = @invoice.transactions
    transactions.first[:date].should eq @invoice_item.created_at
    transactions.first[:description].should eq @invoice_item.item_description
    transactions.first[:quantity].should eq @invoice_item.quantity
    transactions.first[:amount].should eq @invoice_item.amount
  end

  it "should allow you get total payment amount" do
    @invoice.total_payments.should eq 0
  end

  it "should calculate payment_due from its items" do
    @invoice.payment_due.should eq 749.75
  end

  it "should calculate balance from its items and payments" do
    @invoice.balance.should eq 749.75
  end

  it "should allow to check for payments by status" do
    @invoice.has_payments?(:pending).should eq false
    @invoice.has_payments?(:successful).should eq false
  end

  after(:all) do
    @invoice.destroy
    @customer.destroy
  end

end
