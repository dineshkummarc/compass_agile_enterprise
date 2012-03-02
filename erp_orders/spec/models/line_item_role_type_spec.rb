require 'spec_helper'

describe LineItemRoleType do
  it "can be instantiated" do
    LineItemRoleType.new.should be_an_instance_of(LineItemRoleType)
  end

  it "can be saved successfully" do
    LineItemRoleType.create().should be_persisted
  end
end
