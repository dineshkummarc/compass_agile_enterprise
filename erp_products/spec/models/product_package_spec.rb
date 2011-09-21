require 'spec_helper'

describe ProductPackage do
  it "can be instantiated" do
    ProductPackage.new.should be_an_instance_of(ProductPackage)
  end

  it "can be saved successfully" do
    ProductPackage.create().should be_persisted
  end
end

