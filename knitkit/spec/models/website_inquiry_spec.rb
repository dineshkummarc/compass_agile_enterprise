require 'spec_helper'

describe WebsiteInquiry do
  it "can be instantiated" do
    WebsiteInquiry.new.should be_an_instance_of(WebsiteInquiry)
  end

  it "can be saved successfully" do
    WebsiteInquiry.create().should be_persisted
  end
end