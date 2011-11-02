require 'spec_helper'

describe CommunicationEvent do
  it "can be instantiated" do
    CommunicationEvent.new.should be_an_instance_of(CommunicationEvent)
  end

  it "can be saved successfully" do
    from_role = RoleType.create(:internal_identifier => 'test')
    from_party = Party.create(:description => 'test party')
    CommunicationEvent.create(:from_role => from_role, :from_party => from_party).should be_persisted
  end
end



