require 'spec_helper'

describe PublishedWebsite do
  it "can be instantiated" do
    PublishedWebsite.new.should be_an_instance_of(PublishedWebsite)
  end

  it "can be saved successfully" do
    PublishedWebsite.create().should be_persisted
  end
end