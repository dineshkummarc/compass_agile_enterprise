require 'spec_helper'

describe Individual do
  it "can be instantiated" do
    Individual.new.should be_an_instance_of(Individual)
  end

  it "can be saved successfully" do
    Individual.create.should be_persisted
  end
  
end