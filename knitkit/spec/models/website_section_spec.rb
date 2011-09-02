require 'spec_helper'

describe WebsiteSection do
  it "can be instantiated" do
    WebsiteSection.new.should be_an_instance_of(WebsiteSection)
  end

  it "can be saved successfully" do
    WebsiteSection.create().should be_persisted
  end
end