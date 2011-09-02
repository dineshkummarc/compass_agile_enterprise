require 'spec_helper'

describe WebsiteNavItem do
  it "can be instantiated" do
    WebsiteNavItem.new.should be_an_instance_of(WebsiteNavItem)
  end

  it "can be saved successfully" do
    WebsiteNavItem.create().should be_persisted
  end
end