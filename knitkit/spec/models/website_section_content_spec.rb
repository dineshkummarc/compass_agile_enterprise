require 'spec_helper'

describe WebsiteSectionContent do
  it "can be instantiated" do
    WebsiteSectionContent.new.should be_an_instance_of(WebsiteSectionContent)
  end

  it "can be saved successfully" do
    WebsiteSectionContent.create().should be_persisted
  end
end