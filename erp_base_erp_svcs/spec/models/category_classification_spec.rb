require 'spec_helper'

describe CategoryClassification do
  it "can be instantiated" do
    CategoryClassification.new.should be_an_instance_of(CategoryClassification)
  end

  it "can be saved successfully" do
    CategoryClassification.create().should be_persisted
  end
end