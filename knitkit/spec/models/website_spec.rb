require 'spec_helper'

describe Website do
  it "can be instantiated" do
    Website.new.should be_an_instance_of(Website)
  end

  it "can be saved successfully" do
    Website.create(:name => 'Test Site').should be_persisted
  end
end