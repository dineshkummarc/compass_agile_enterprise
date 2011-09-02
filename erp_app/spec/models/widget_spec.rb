require 'spec_helper'

describe Widget do
  it "can be instantiated" do
    Widget.new.should be_an_instance_of(Widget)
  end

  it "can be saved successfully" do
    Widget.create().should be_persisted
  end
end