require 'spec_helper'
require 'support/enable_sunspot'

describe 'test content' do
  include EnableSunspot

  before :each do
    @c = Article.create!(
      :title => 'title',
      :excerpt_html => 'excerpt',
      :body_html => 'test content'    
    )
  end

  it 'should return results specified by search' do
    Content.search do
      keywords 'test content'
    end.results.should == [@c]
  end

  it 'should not return results excluded by search' do
    Content.search do
      keywords 'bogus content'
    end.results.should be_empty
  end
  
  it 'should update correctly' do
    @c.update_attribute(:body_html, 'updated content')
    
    Content.search do
      keywords 'updated content'
    end.results.should == [@c]
  end
  
  it 'should destroy correctly' do
    @c.destroy
    
    Content.search do
      keywords 'test content'
    end.results.should be_empty
  end
end


describe 'test party' do
  include EnableSunspot
  
  before :each do
    @party = Party.new
    @party.description = 'John Doe'
    @party.save
  end

  it 'should return results specified by search' do
    PartySearchFact.search do
      with :party_description, 'John Doe'
    end.results.should == [@party.party_search_fact]
  end

  it 'should not return results excluded by search' do
    PartySearchFact.search do
      with :party_description, 'Bogus Party'
    end.results.should be_empty
  end
  
  it 'should update correctly' do
    @party.description = 'Bob Doe'
    @party.save
    
    PartySearchFact.search do
      with :party_description, 'Bob Doe'
    end.results.should == [@party.party_search_fact]
  end
end

describe 'test individual' do
  include EnableSunspot
  
  before :each do
    @i = Individual.new
    @i.current_first_name = 'John'
    @i.current_last_name = 'Doe'
    @i.save
    
    @party = @i.party
  end

  it 'should return results specified by search' do
    PartySearchFact.search do
      with :party_description, 'John Doe'
    end.results.should == [@party.party_search_fact]
  end

  it 'should not return results excluded by search' do
    PartySearchFact.search do
      with :party_description, 'Bogus Party'
    end.results.should be_empty
  end
  
  it 'should update correctly' do
    @party.business_party.current_first_name = 'Bob'
    @party.business_party.current_last_name = 'Doe'
    @party.business_party.save
    
    PartySearchFact.search do
      keywords 'Bob Doe'
    end.results.should == [@party.party_search_fact]
  end
end

describe 'test phone number' do
  include EnableSunspot
  
  before :each do
    personal = ContactPurpose.find_by_internal_identifier('personal')
    personal = ContactPurpose.create(:internal_identifier => 'personal', :description => 'Personal') if personal.nil?
    
    @party = Party.new
    @party.description = 'John Doe'
    @party.save
    @party.update_or_add_contact_with_purpose(PhoneNumber, personal, :phone_number => '123-456-7890')
  end

  it 'should return results specified by search' do
    PartySearchFact.search do
      keywords '123-456-7890'
    end.results.should == [@party.party_search_fact]
  end

  it 'should not return results excluded by search' do
    PartySearchFact.search do
      keywords '000-000-0000'
    end.results.should be_empty
  end
  
  it 'should update correctly' do
    phone = @party.personal_phone_number
    phone.phone_number = '333-333-3333'
    phone.save
    
    PartySearchFact.search do
      keywords '333-333-3333'
    end.results.should == [@party.party_search_fact]
  end

  it 'should destroy correctly' do
    phone = @party.personal_phone_number
    phone.destroy
    
    PartySearchFact.search do
      keywords '123-456-7890'
    end.results.should be_empty
  end
end

describe 'test email address' do
  include EnableSunspot
  
  before :each do
    personal = ContactPurpose.find_by_internal_identifier('personal')
    personal = ContactPurpose.create(:internal_identifier => 'personal', :description => 'Personal') if personal.nil?
    
    @party = Party.new
    @party.description = 'John Doe'
    @party.save
    @party.update_or_add_contact_with_purpose(EmailAddress, personal, :email_address => 'john@doe.com')      	
  end

  it 'should return results specified by search' do
    PartySearchFact.search do
      keywords 'john@doe.com'
    end.results.should == [@party.party_search_fact]
  end

  it 'should not return results excluded by search' do
    PartySearchFact.search do
      keywords 'no@email.com'
    end.results.should be_empty
  end
  
  it 'should update correctly' do
    email = @party.personal_email_address
    email.email_address = 'updated@email.com'
    email.save
    
    PartySearchFact.search do
      keywords 'updated@email.com'
    end.results.should == [@party.party_search_fact]
  end

  it 'should destroy correctly' do
    email = @party.personal_email_address
    email.destroy
    
    PartySearchFact.search do
      keywords 'john@doe.com'
    end.results.should be_empty
  end
end

describe 'test postal address' do
  include EnableSunspot
  
  before :each do
    home = ContactPurpose.find_by_internal_identifier('home')
    home = ContactPurpose.create(:internal_identifier => 'home', :description => 'Home') if home.nil?
    
    @party = Party.new
    @party.description = 'John Doe'
    @party.save

    postal_address_args = {
      :address_line_1 => '123 Main Street',
      :address_line_2 => 'BOX 123',
      :city => 'Orlando',
      :state => 'FL',
      :zip => '32724',
      :country => 'US'
    }

    @party.update_or_add_contact_with_purpose(PostalAddress, home, postal_address_args)
  end

  it 'should return results specified by search' do
    PartySearchFact.search do
      with :party_address_1, '123 Main Street'
    end.results.should == [@party.party_search_fact]
  end

  it 'should not return results excluded by search' do
    PartySearchFact.search do
      with :party_address_1, 'Bogus Address'
    end.results.should be_empty
  end
  
  it 'should update correctly' do
    address = @party.home_postal_address
    address.address_line_1 = '1 Orange Ave'
    address.save
    
    PartySearchFact.search do
      with :party_address_1, '1 Orange Ave'
    end.results.should == [@party.party_search_fact]
  end

  it 'should destroy correctly' do
    address = @party.home_postal_address
    address.destroy
    
    PartySearchFact.search do
      with :party_address_1, '123 Main Street'
    end.results.should be_empty
  end
end