require 'spec_helper'

describe Content do
  it "can be instantiated" do
    Content.new.should be_an_instance_of(Content)
  end

  #it "can be saved successfully" do
  #  Content.create(:type => 'Page', :title => 'Test').should be_persisted
  #end
end