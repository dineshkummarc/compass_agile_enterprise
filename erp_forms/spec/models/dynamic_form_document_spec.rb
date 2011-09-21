require 'spec_helper'

describe DynamicFormDocument do
  it "can be instantiated" do
    DynamicFormDocument.new.should be_an_instance_of(DynamicFormDocument)
  end

  it "can be saved successfully" do
    DynamicFormDocument.create().should be_persisted
  end
end