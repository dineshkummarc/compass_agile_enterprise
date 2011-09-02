require 'spec_helper'

describe UserPreference do
  it "can be instantiated" do
    UserPreference.new.should be_an_instance_of(UserPreference)
  end

  it "can be saved successfully" do
    UserPreference.create().should be_persisted
  end
end