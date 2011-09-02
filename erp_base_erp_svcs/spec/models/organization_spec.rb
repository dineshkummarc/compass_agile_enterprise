require 'spec_helper'

describe Organization do
  it "can be instantiated" do
    Organization.new.should be_an_instance_of(Organization)
  end

  it "can be saved successfully" do
    Organization.create().should be_persisted
  end
  
  it "creates party" do
    organization = Organization.create(:description => 'Worldcom')
    organization.should be_an_instance_of(Organization)
    organization.party.should be_an_instance_of(Party) 
    organization.party.description.should == "Worldcom"
    organization.party.business_party.should == organization
  end
  
  it "destroys party" do
    organization = Organization.create(:description => 'Worldcom')
    organization.should be_an_instance_of(Organization)
    
    party = organization.party
    organization.party.should be_an_instance_of(Party) 
    organization.party.description.should == "Worldcom"
    organization.party.business_party.should == organization
    
    organization.destroy
    Party.where("id = ?",party.id).count.should == 0
  end
  
end