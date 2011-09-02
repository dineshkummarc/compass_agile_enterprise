require 'spec_helper'

describe Article do
  it "can be instantiated" do
    Article.new.should be_an_instance_of(Article)
  end

  it "can be saved successfully" do
    Article.create().should be_persisted
  end
end