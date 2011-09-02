require 'spec_helper'

describe Individual do
  it "can be instantiated" do
    Individual.new.should be_an_instance_of(Individual)
  end

  it "can be saved successfully" do
    Individual.create.should be_persisted
  end
  
  it "creates party" do
    individual = Individual.create(:current_first_name => 'Dummy', :current_last_name => 'Person')
    individual.should be_an_instance_of(Individual)
    individual.party.should be_an_instance_of(Party) 
    individual.party.description.should == "Dummy Person"
    individual.party.business_party.should == individual
  end
  
  it "destroys party" do
    individual = Individual.create(:current_first_name => 'Dummy', :current_last_name => 'Person')
    individual.should be_an_instance_of(Individual)
    
    party = individual.party
    individual.party.should be_an_instance_of(Party) 
    individual.party.description.should == "Dummy Person"
    individual.party.business_party.should == individual
    
    individual.destroy
    Party.where("id = ?",party.id).count.should == 0
  end
  
  it "should have encrypted ssn" do
    individual = Individual.create(:current_first_name => 'Dummy', :current_last_name => 'Person')
    individual.social_security_number = "123212323"
    individual.encrypted_ssn.should_not == "123212323"
    individual.social_security_number.should == "123212323"
  end
  
end