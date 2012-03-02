require 'spec_helper'

describe Application do
  it "can be instantiated" do
    Application.new.should be_an_instance_of(Application)
  end

  it "can be saved successfully" do
    Application.create().should be_persisted
  end
end