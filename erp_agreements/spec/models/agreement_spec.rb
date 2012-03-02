require 'spec_helper'

describe Agreement do
  it "can be instantiated" do
    agreement = Factory.build(:agreement, :description => 'My Agreement')
    agreement.should be_an_instance_of(Agreement)
  end

  it "can be saved successfully" do
    agreement = Factory.build(:agreement, :description => 'My Agreement')
    agreement.save.should eq true
  end
  
  it "can use agreement items as methods" do
    agreement_item_type = Factory.build(:agreement_item_type, :internal_identifier => 'reference_number')
    agreement_item = Factory.build(:agreement_item, :agreement_item_type => agreement_item_type, :agreement_item_value => '1234ABCD')
    agreement = Factory.build(:agreement, :description => 'My Agreement')
    agreement.items << agreement_item
    agreement.save!
    agreement.reference_number.should == '1234ABCD'
  end

  it "can have agreement relationships" do
    agreement_reln_type = Factory.build(:agreement_reln_type, :internal_identifier => 'test_reln_type', :description => 'test reln type')
    agreement_reln = Factory.build(:agreement_relationship, :description => 'test reln',
                                                            :relationship_type => agreement_reln_type)
    agreement_one = Factory.build(:agreement, :description => 'Agreement One')
    agreement_two = Factory.build(:agreement, :description => 'Agreement two')
    
    agreement_reln.agreement_from = agreement_one
    agreement_reln.agreement_to = agreement_two
    agreement_reln.save

    agreement_one.agreement_relationships.collect(&:description).first.should eq "test reln"
    agreement_two.agreement_relationships.collect(&:description).first.should eq "test reln"
  end

  it "has a method to_s that returns description" do
    agreement = Factory(:agreement, :description => 'My Agreement')
    agreement.to_s.should eq 'My Agreement'
  end

  it "has a method to_label that calls to_s which returns description" do
    agreement = Factory(:agreement, :description => 'My Agreement')
    agreement.to_label.should eq 'My Agreement'
  end

  it "can find paties by roles" do
    #TODO this needs to factored to use erp_base_base_erp_svcs factories
    party = Factory(:party, :description => 'Joe Smith')
    role_type = Factory(:role_type, :description => 'owner', :internal_identifier => 'owner')

    agreement = Factory(:agreement, :description => 'My Agreement')
    agreement_party_role = Factory(:agreement_party_role,
                                   :description => 'My Agreement',
                                   :role_type => role_type,
                                   :party => party,
                                   :agreement => agreement)

    agreement.find_parties_by_role(RoleType.iid('owner')).first.id.should eq party.id
  end
  
end