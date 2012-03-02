require 'spec_helper'

describe ProductType do
  it "can be instantiated" do
    ProductType.new.should be_an_instance_of(ProductType)
  end

  it "can be saved successfully" do
    ProductType.create().should be_persisted
  end
end


