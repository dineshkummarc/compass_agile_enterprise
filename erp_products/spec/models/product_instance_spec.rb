require 'spec_helper'

describe ProductInstance do
  it "can be instantiated" do
    ProductInstance.new.should be_an_instance_of(ProductInstance)
  end

  it "can be saved successfully" do
    ProductInstance.create().should be_persisted
  end
end


