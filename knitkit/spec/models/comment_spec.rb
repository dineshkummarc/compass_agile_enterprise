require 'spec_helper'

describe Comment do
  it "can be instantiated" do
    Comment.new.should be_an_instance_of(Comment)
  end

  it "can be saved successfully" do
    Comment.create().should be_persisted
  end
end