require 'spec_helper'

describe Cost do
  it "can be instantiated" do
    Cost.new.should be_an_instance_of(Cost)
  end

  it "can be saved successfully" do
    Cost.create().should be_persisted
  end
end