require 'spec_helper'

describe ProdInstanceRelnType do
  it "can be instantiated" do
    ProdInstanceRelnType.new.should be_an_instance_of(ProdInstanceRelnType)
  end

  it "can be saved successfully" do
    ProdInstanceRelnType.create().should be_persisted
  end
end