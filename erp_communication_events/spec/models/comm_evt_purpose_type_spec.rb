require 'spec_helper'

describe CommEvtPurposeType do
  it "can be instantiated" do
    CommEvtPurposeType.new.should be_an_instance_of(CommEvtPurposeType)
  end

  it "can be saved successfully" do
    CommEvtPurposeType.create().should be_persisted
  end
end
