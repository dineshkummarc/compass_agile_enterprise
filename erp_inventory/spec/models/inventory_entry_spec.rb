require 'spec_helper'

describe InventoryEntry do
  it "can be instantiated" do
    InventoryEntry.new.should be_an_instance_of(InventoryEntry)
  end

  it "can be saved successfully" do
    InventoryEntry.create().should be_persisted
  end
end