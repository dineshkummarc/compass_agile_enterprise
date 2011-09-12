require 'spec_helper'

describe Desktop do
  it "can be instantiated" do
    Desktop.new.should be_an_instance_of(Desktop)
  end

  it "can be saved successfully" do
    Desktop.create().should be_persisted
  end
end