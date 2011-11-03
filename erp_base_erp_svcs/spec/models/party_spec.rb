require 'spec_helper'

describe Party do
  it "can be instantiated" do
    Party.new.should be_an_instance_of(Party)
  end

  it "can be saved successfully" do
    Party.create.should be_persisted
  end

  it "has method to check for phone number passing in number" do
    party = Factory(:party)
    contact_purpose = Factory(:contact_purpose, :description => 'billing', :internal_identifier => 'billing')
    party.update_or_add_contact_with_purpose(PhoneNumber, contact_purpose, :phone_number => '123-123-1234')
    party.has_phone_number?('123-123-1234').should eq true
  end

  it "has method to check for zip code passing in zip code" do
    party = Factory(:party)
    contact_purpose = Factory(:contact_purpose, :description => 'billing', :internal_identifier => 'billing')
    party.update_or_add_contact_with_purpose(PostalAddress, contact_purpose, :zip => '34711')
    party.has_zip_code?('34711').should eq true
  end

  it "has method to_label to return description" do
    party = Factory(:party, :description => 'Joe Smith')
    party.to_label.should eq "Joe Smith"
  end

  it "has method to_s to return description" do
    party = Factory(:party, :description => 'Joe Smith')
    party.to_s.should eq "Joe Smith"
  end

  it "overrids respond_to? and method_missing to find contacts" do
    party = Factory(:party)
    contact_purpose = Factory(:contact_purpose, :description => 'billing', :internal_identifier => 'billing')
    party.update_or_add_contact_with_purpose(PhoneNumber, contact_purpose, :phone_number => '123-123-1234')
    party.billing_phone_number.should_not eq nil
    party.billing_phone_number.phone_number.should eq '123-123-1234'
  end

  it "has method to get all contacts by contact mechanism" do
    party = Factory(:party)
    contact_purpose_billing = Factory(:contact_purpose, :description => 'billing', :internal_identifier => 'billing')
    contact_purpose_home = Factory(:contact_purpose, :description => 'home', :internal_identifier => 'home')
    party.update_or_add_contact_with_purpose(PhoneNumber, contact_purpose_billing, :phone_number => '123-123-1234')
    party.update_or_add_contact_with_purpose(PhoneNumber, contact_purpose_home, :phone_number => '123-123-1234')

    party.find_all_contacts_by_contact_mechanism(PhoneNumber).count.should eq 2
  end

  it "has method to find contact with a contact purpose and can take internal identifier of contact purpose" do
    party = Factory(:party)
    contact_purpose_billing = Factory(:contact_purpose, :description => 'billing', :internal_identifier => 'billing')
    party.update_or_add_contact_with_purpose(PhoneNumber, contact_purpose_billing, :phone_number => '123-123-1234')

    party.find_contact_with_purpose(PhoneNumber, 'billing').contact_mechanism.phone_number.should eq '123-123-1234'
  end

  it "has method to find contact with a contact purpose and can take a contact purpose instance" do
    party = Factory(:party)
    contact_purpose_billing = Factory(:contact_purpose, :description => 'billing', :internal_identifier => 'billing')
    party.update_or_add_contact_with_purpose(PhoneNumber, contact_purpose_billing, :phone_number => '123-123-1234')

    party.find_contact_with_purpose(PhoneNumber, contact_purpose_billing).contact_mechanism.phone_number.should eq '123-123-1234'
  end

  it "can update contact" do
    party = Factory(:party)
    contact_purpose_billing = Factory(:contact_purpose, :description => 'billing', :internal_identifier => 'billing')
    party.update_or_add_contact_with_purpose(PhoneNumber, contact_purpose_billing, :phone_number => '123-123-1234')

    party.find_contact_with_purpose(PhoneNumber, contact_purpose_billing).contact_mechanism.phone_number.should eq '123-123-1234'

    party.update_contact(PhoneNumber, party.find_contact_with_purpose(PhoneNumber, contact_purpose_billing), :phone_number => '123-123-1235')

    party.find_contact_with_purpose(PhoneNumber, contact_purpose_billing).contact_mechanism.phone_number.should eq '123-123-1235'
  end

  it "should update contact if contact already exists" do
    party = Factory(:party)
    contact_purpose_billing = Factory(:contact_purpose, :description => 'billing', :internal_identifier => 'billing')
    party.update_or_add_contact_with_purpose(PhoneNumber, contact_purpose_billing, :phone_number => '123-123-1234')

    current_contact = party.find_contact_with_purpose(PhoneNumber, contact_purpose_billing)
    current_contact.contact_mechanism.phone_number.should eq '123-123-1234'

    party.update_or_add_contact_with_purpose(PhoneNumber, contact_purpose_billing, :phone_number => '123-123-1235')

    new_contact = party.find_contact_with_purpose(PhoneNumber, contact_purpose_billing)
    new_contact.contact_mechanism.phone_number.should eq '123-123-1235'
    new_contact.id.should eq current_contact.id

  end


end