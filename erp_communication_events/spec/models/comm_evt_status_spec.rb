require 'spec_helper'

describe CommEvtStatus do
  it "can be instantiated" do
    CommEvtStatus.new.should be_an_instance_of(CommEvtStatus)
  end

  it "can be saved successfully" do
    CommEvtStatus.create().should be_persisted
  end
end

