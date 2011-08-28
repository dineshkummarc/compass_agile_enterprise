require 'spec_helper'

describe RelationshipType do
  it "can be instantiated" do
    RelationshipType.new.should be_an_instance_of(RelationshipType)
  end

  it "can be saved successfully" do
    RelationshipType.create().should be_persisted
  end
end