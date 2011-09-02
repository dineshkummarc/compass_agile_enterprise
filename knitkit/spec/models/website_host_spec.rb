require 'spec_helper'

describe WebsiteHost do
  it "can be instantiated" do
    WebsiteHost.new.should be_an_instance_of(WebsiteHost)
  end

  it "can be saved successfully" do
    WebsiteHost.create().should be_persisted
  end
end