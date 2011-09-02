require 'spec_helper'

describe PreferenceOption do
  it "can be instantiated" do
    PreferenceOption.new.should be_an_instance_of(PreferenceOption)
  end

  it "can be saved successfully" do
    PreferenceOption.create().should be_persisted
  end
end