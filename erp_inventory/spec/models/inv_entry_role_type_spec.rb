require 'spec_helper'

describe InvEntryRoleType do
  it "can be instantiated" do
    InvEntryRoleType.new.should be_an_instance_of(InvEntryRoleType)
  end

  it "can be saved successfully" do
    InvEntryRoleType.create().should be_persisted
  end
end



