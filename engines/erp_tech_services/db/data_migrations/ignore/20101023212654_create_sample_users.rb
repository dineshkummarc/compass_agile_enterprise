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
    
    #Admin additional
    ['Russell', 'Rick'].each do |name|
      individual = Individual.find(:first, :conditions => ['current_first_name = ?', name])
      user = User.create(
        :login => (individual.current_first_name[0..0] + individual.current_last_name).downcase,
        :email => "#{(individual.current_first_name[0..0] + individual.current_last_name).downcase}@gmail.com"
      )
      user.password = 'password'
      user.password_confirmation = 'password'
      user.activated_at = Time.now
      user.enabled = true
      user.party = individual.party
      user.save
      user.roles << Role.iid('admin')
      user.save
    end

    #Employees
    ['John', 'Timothy'].each do |name|
      individual = Individual.find(:first, :conditions => ['current_first_name = ?', name])
      user = User.create(
        :login => (individual.current_first_name[0..0] + individual.current_last_name).downcase,
        :email => "#{(individual.current_first_name[0..0] + individual.current_last_name).downcase}@gmail.com"
      )
      user.password = 'password'
      user.password_confirmation = 'password'
      user.activated_at = Time.now
      user.enabled = true
      user.party = individual.party
      user.save
      user.roles << Role.iid('employee')
      user.save
    end

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
    ['rholmes', 'rkoloski', 'jholmes', 'tholmes', 'truenorth'].each do |name|
      user = User.find_by_login(name)
      user.destroy unless user.nil?
    end
  end

end
