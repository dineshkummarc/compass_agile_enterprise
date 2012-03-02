require 'spec_helper'

describe ProdInstanceInvEntry do
  it "can be instantiated" do
    ProdInstanceInvEntry.new.should be_an_instance_of(ProdInstanceInvEntry)
  end

  it "can be saved successfully" do
    ProdInstanceInvEntry.create().should be_persisted
  end
end
