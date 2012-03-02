require 'spec_helper'

describe PaymentApplication do

  before(:all) do
    @payment_application = PaymentApplication.create()
  end

  it "should have to check to see if it is pending" do
    @payment_application.is_pending?.should eq false
  end

  after(:all) do
    @payment_application.destroy
  end

end
