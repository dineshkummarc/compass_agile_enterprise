require 'spec_helper'

describe ProdTypeReln do
  it "can be instantiated" do
    ProdTypeReln.new.should be_an_instance_of(ProdTypeReln)
  end

  it "can be saved successfully" do
    ProdTypeReln.create().should be_persisted
  end
end
