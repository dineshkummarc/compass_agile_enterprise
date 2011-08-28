require 'spec_helper'

describe RoleType do
  it "can be instantiated" do
    RoleType.new.should be_an_instance_of(RoleType)
  end

  it "can be saved successfully" do
    RoleType.create.should be_persisted
  end

end