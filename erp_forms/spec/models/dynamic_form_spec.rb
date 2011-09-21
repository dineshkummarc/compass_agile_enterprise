require 'spec_helper'

describe DynamicForm do
  it "can be instantiated" do
    DynamicForm.new.should be_an_instance_of(DynamicForm)
  end

  it "can be saved successfully" do
    DynamicForm.create().should be_persisted
  end
end
