require 'spec_helper'

describe CommEvtStatusType do
  it "can be instantiated" do
    CommEvtStatusType.new.should be_an_instance_of(CommEvtStatusType)
  end

  it "can be saved successfully" do
    CommEvtStatusType.create().should be_persisted
  end
end


