require 'spec_helper'

describe ViewType do
  it "can be instantiated" do
    ViewType.new.should be_an_instance_of(ViewType)
  end

  it "can be saved successfully" do
    ViewType.create.should be_persisted
  end

end