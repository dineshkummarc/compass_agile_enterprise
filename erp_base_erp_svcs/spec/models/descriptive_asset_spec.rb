require 'spec_helper'

describe DescriptiveAsset do
  it "can be instantiated" do
    DescriptiveAsset.new.should be_an_instance_of(DescriptiveAsset)
  end

  it "can be saved successfully" do
    DescriptiveAsset.create.should be_persisted
  end
  
end