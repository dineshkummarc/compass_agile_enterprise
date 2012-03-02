require 'spec_helper'

describe Theme do
  it "can be instantiated" do
    Theme.new.should be_an_instance_of(Theme)
  end

  #it "can be saved successfully" do
  #  website = Website.create(:name => 'Test Site')
  #  Theme.create(:name => 'Test', :website => website).should be_persisted
  #end
end