require 'spec_helper'

describe GlAccount do
  it "can be instantiated" do
    GlAccount.new.should be_an_instance_of(GlAccount)
  end

  it "can be saved successfully" do
    GlAccount.create().should be_persisted
  end
end
