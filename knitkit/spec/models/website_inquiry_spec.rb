require 'spec_helper'

describe WebsiteInquiry do
  before do
    @website = Website.create(:name => "Some Site")
  end
  it "can be instantiated" do
    WebsiteInquiry.new.should be_an_instance_of(WebsiteInquiry)
  end

  it "can be saved successfully" do
    WebsiteInquiry.create().should be_persisted
  end

  describe "send_email" do
    it "should call WebsiteInquiryMailer.inquiry (ask adam about this)" #do
      #@website_inquiry = WebsiteInquiry.create
      #@website.website_inquiries << @website_inquiry
      #WebsiteInquiryMailer.should_receive(:inquiry).with(@website_inquiry).and_return()
      #@website_inquiry.send_email

    #end
  end
end