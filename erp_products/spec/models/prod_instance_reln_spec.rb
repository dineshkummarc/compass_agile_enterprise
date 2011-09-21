require 'spec_helper'

describe ProdInstanceReln do
  it "can be instantiated" do
    ProdInstanceReln.new.should be_an_instance_of(ProdInstanceReln)
  end

  it "can be saved successfully" do
    ProdInstanceReln.create().should be_persisted
  end
end