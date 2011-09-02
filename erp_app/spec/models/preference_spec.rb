require 'spec_helper'

describe Preference do
  it "can be instantiated" do
    Preference.new.should be_an_instance_of(Preference)
  end

  it "can be saved successfully" do
    Preference.create().should be_persisted
  end
end