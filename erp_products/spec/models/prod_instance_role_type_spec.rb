require 'spec_helper'

describe ProdInstanceRoleType do
  it "can be instantiated" do
    ProdInstanceRoleType.new.should be_an_instance_of(ProdInstanceRoleType)
  end

  it "can be saved successfully" do
    ProdInstanceRoleType.create().should be_persisted
  end
end