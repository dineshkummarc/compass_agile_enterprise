class CreateSampleParties
  
  def self.up
    #Admins
    Individual.create(:current_first_name => 'Admin',:current_last_name => 'Istrator',:gender => 'm')

    #Organization
    Organization.create(:description => 'TrueNorth')
  end
  
  def self.down
    ['Admin'].each do |name|
      individual = Individual.find_by_current_first_name(name)
      individual.destroy unless individual.nil?
    end

    ['TrueNorth'].each do |name|
      organization = Organization.find_by_description(name)
      organization.destroy unless organization.nil?
    end
  end

end
