require 'spec_helper'

describe AgreementRelationship do
  it "can be instantiated" do
    AgreementRelationship.new.should be_an_instance_of(AgreementRelationship)
  end

  it "can be saved successfully" do
    AgreementRelationship.create().should be_persisted
  end

  describe "can return an instance of this class with the from_role, to_role and relationship_type set" do
    
    before(:each) do
      #TODO this needs to factored to use erp_base_base_erp_svcs factories
      @seller_role_type = AgreementRoleType.create(:description => 'seller', :internal_identifier => 'seller')
      @buyer_role_type = AgreementRoleType.create(:description => 'buyer', :internal_identifier => 'buyer')

      @agreement_reln_type = Factory(:agreement_reln_type,
        :description => 'Buyer Seller',
        :internal_identifier => 'buyer_seller',
        :valid_from_role => @seller_role_type,
        :valid_to_role => @buyer_role_type)
    end

    it "has method to take AgreementRelnType instance" do
      agreement_relationship = AgreementRelationship.for_relationship_type(@agreement_reln_type)

      agreement_relationship.should be_an_instance_of(AgreementRelationship)
      agreement_relationship.from_role.id.should eq @seller_role_type.id
      agreement_relationship.to_role.id.should eq @buyer_role_type.id
      agreement_relationship.relationship_type.id.should eq @agreement_reln_type.id
    end

    it "has method (for_relationship_type_identifier) to take internal identifer of AgreementRelnType" do
      agreement_relationship = AgreementRelationship.for_relationship_type_identifier('buyer_seller')

      agreement_relationship.should be_an_instance_of(AgreementRelationship)
      agreement_relationship.from_role.id.should eq @seller_role_type.id
      agreement_relationship.to_role.id.should eq @buyer_role_type.id
      agreement_relationship.relationship_type.id.should eq @agreement_reln_type.id
    end

    it "has shortcut method (for_reln_type_id) to take internal identifer of AgreementRelnType" do
      agreement_relationship = AgreementRelationship.for_reln_type_id('buyer_seller')

      agreement_relationship.should be_an_instance_of(AgreementRelationship)
      agreement_relationship.from_role.id.should eq @seller_role_type.id
      agreement_relationship.to_role.id.should eq @buyer_role_type.id
      agreement_relationship.relationship_type.id.should eq @agreement_reln_type.id
    end
    
  end

end
