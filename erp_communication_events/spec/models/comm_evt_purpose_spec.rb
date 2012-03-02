require 'spec_helper'

describe CommEvtPurpose do
  it "can be instantiated" do
    CommEvtPurpose.new.should be_an_instance_of(CommEvtPurpose)
  end

  it "can be saved successfully" do
    CommEvtPurpose.create().should be_persisted
  end
end

