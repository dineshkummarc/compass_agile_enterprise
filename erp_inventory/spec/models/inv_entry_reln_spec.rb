require 'spec_helper'

describe InvEntryReln do
  it "can be instantiated" do
    InvEntryReln.new.should be_an_instance_of(InvEntryReln)
  end

  it "can be saved successfully" do
    InvEntryReln.create().should be_persisted
  end
end

