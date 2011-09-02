require 'spec_helper'

describe DesktopApplication do
  it "can be instantiated" do
    DesktopApplication.new.should be_an_instance_of(DesktopApplication)
  end

  it "can be saved successfully" do
    DesktopApplication.create().should be_persisted
  end
end