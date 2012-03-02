require 'spec_helper'

describe PreferenceType do
  it "can be instantiated" do
    PreferenceType.new.should be_an_instance_of(PreferenceType)
  end

  it "can be saved successfully" do
    PreferenceType.create().should be_persisted
  end
end