require 'spec_helper'

describe ProdTypeRoleType do
  it "can be instantiated" do
    ProdTypeRoleType.new.should be_an_instance_of(ProdTypeRoleType)
  end

  it "can be saved successfully" do
    ProdTypeRoleType.create().should be_persisted
  end
end

