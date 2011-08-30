require 'spec_helper'

describe AppContainer do
  it "can be instantiated" do
    AppContainer.new.should be_an_instance_of(AppContainer)
  end

  it "can be saved successfully" do
    AppContainer.create().should be_persisted
  end
end