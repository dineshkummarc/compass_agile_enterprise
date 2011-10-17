require 'spec_helper'

describe Party do
  before(:each) do
    @party = Factory.create(:individual_party)
    @party_relationship = Factory.create(:party_relationship, :from_party => @party)
  end

  it "relationships count should be 1" do
    @relationships = @party.relationships
    @relationships.count.should eq 1
  end

  it "Create a new relationship, and count of relationships should be 2" do
    @party2 = Factory.create(:individual_party)
    @party.create_relationship("Created a new relationship for a test", @party2.id)
    @party.relationships.count.should eq 2
  end

  it "Should find relationships by type and get an array with 1 relationship" do
    @relationship_type = Factory.create(:relationship_type,
                                        :internal_identifier => "Test Relationship Type")

    @relationship1 = Factory.create(:party_relationship,
                                    :from_party => @party,
                                    :relationship_type => @relationship_type
                                   )
    @party.find_relationships_by_type("Test Relationship Type").count.should eq 1
  end

  it "find_relationships_by_type should return no relationships, no error" do
    PartyRelationship.destroy(@party_relationship.id)
    @party.find_relationships_by_type("Test Relationship Type").count.should eq 0
  end
end

