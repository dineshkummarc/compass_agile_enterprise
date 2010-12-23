class CreateSampleParties
  
  def self.up
    #Admins
    Individual.create(:current_first_name => 'Admin',:current_last_name => 'Istrator',:gender => 'm')
    Individual.create(:current_first_name => 'Russell',:current_last_name => 'Holmes',:gender => 'm')
    Individual.create(:current_first_name => 'Rick',:current_last_name => 'Koloski',:gender => 'm')

    #Employees
    Individual.create(:current_first_name => 'John',:current_last_name => 'Holmes',:gender => 'm')
    Individual.create(:current_first_name => 'Timothy',:current_last_name => 'Holmes',:gender => 'm')

    #Customers
    Individual.create(:current_first_name => 'Daniel',:current_last_name => 'Brady',:gender => 'm')
    Individual.create(:current_first_name => 'Kevin',:current_last_name => 'Chancey',:gender => 'm')

    #Organization
    Organization.create(:description => 'TrueNorth')
  end
  
  def self.down
    ['Admin', 'Russell', 'Rick', 'John', 'Timothy', 'Daniel', 'Kevin'].each do |name|
      individual = Individual.find_by_current_first_name(name)
      individual.destroy unless individual.nil?
    end

    ['TrueNorth'].each do |name|
      organization = Organization.find_by_description(name)
      organization.destroy unless organization.nil?
    end
  end

end
