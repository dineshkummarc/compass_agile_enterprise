require 'spec_helper'

describe WebsiteNav do
  it "can be instantiated" do
    WebsiteNav.new.should be_an_instance_of(WebsiteNav)
  end

  it "can be saved successfully" do
    WebsiteNav.create().should be_persisted
  end
end