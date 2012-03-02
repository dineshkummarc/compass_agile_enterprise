require 'spec_helper'

describe InvoiceItem do

  before(:all) do
    @invoice_item = InvoiceItem.create(:amount => 29.99, :quantity => 25, :item_description => '7619851 BICEP II MAGNUM 2X2.5GA')
  end

  it "should calculate total amount" do
    @invoice_item.total_amount.should eq 749.75
  end

  it "should allow to check for payments by status" do
    @invoice_item.has_payments?(:pending).should eq false
    @invoice_item.has_payments?(:successful).should eq false
  end

  after(:all) do
    @invoice_item.destroy
  end

end
