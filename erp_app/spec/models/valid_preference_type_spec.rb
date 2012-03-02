require 'spec_helper'

describe ValidPreferenceType do
  it "can be instantiated" do
    ValidPreferenceType.new.should be_an_instance_of(ValidPreferenceType)
  end

  it "can be saved successfully" do
    ValidPreferenceType.create().should be_persisted
  end
end