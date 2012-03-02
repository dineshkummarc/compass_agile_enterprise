require 'spec_helper'

describe DynamicDatum do
  it "can be instantiated" do
    DynamicDatum.new.should be_an_instance_of(DynamicDatum)
  end

  it "can be saved successfully"
end