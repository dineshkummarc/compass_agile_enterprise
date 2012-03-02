require 'spec_helper'

describe DynamicFormModel do
  it "can be instantiated" do
    DynamicFormModel.new.should be_an_instance_of(DynamicFormModel)
  end

  it "can be saved successfully" do
    DynamicFormModel.create().should be_persisted
  end
end