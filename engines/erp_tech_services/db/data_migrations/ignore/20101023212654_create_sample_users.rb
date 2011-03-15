class CreateSampleUsers
  
  def self.up
    #Admins root
    
    root_individual= Individual.find(:first, :conditions => ['current_first_name = ?',"Admin"])
    root_user=User.create(
      :login => "admin",
      :email => "admin@portablemind.com"
    )
    root_user.password = 'password'
    root_user.password_confirmation = 'password'
    root_user.activated_at = Time.now
    root_user.enabled = true
    root_user.party = root_individual.party
    root_user.save
    root_user.roles << Role.iid('admin')
    root_user.save

    #Organizations
    ['TrueNorth'].each do |name|
      organization = Organization.find(:first, :conditions => ['description = ?', name])
      user = User.create(
        :login => organization.description.downcase,
        :email => "#{organization.description.downcase}@gmail.com"
      )
      user.password = 'password'
      user.password_confirmation = 'password'
      user.activated_at = Time.now
      user.enabled = true
      user.party = organization.party
      user.save
      user.roles << Role.iid('admin')
      user.save
    end
  end
  
  def self.down
    ['truenorth', 'admin'].each do |name|
      user = User.find_by_login(name)
      user.destroy unless user.nil?
    end
  end

end
