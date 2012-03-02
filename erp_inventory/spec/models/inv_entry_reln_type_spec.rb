require 'spec_helper'

describe InvEntryRelnType do
  it "can be instantiated" do
    InvEntryRelnType.new.should be_an_instance_of(InvEntryRelnType)
  end

  it "can be saved successfully" do
    InvEntryRelnType.create().should be_persisted
  end
end


