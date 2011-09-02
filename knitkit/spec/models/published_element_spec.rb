require 'spec_helper'

describe PublishedElement do
  it "can be instantiated" do
    PublishedElement.new.should be_an_instance_of(PublishedElement)
  end

  it "can be saved successfully" do
    PublishedElement.create().should be_persisted
  end
end