require 'spec_helper'

describe ProdTypeRelnType do
  it "can be instantiated" do
    ProdTypeRelnType.new.should be_an_instance_of(ProdTypeRelnType)
  end

  it "can be saved successfully" do
    ProdTypeRelnType.create().should be_persisted
  end
end

