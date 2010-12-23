class SetUpFirstAdminUser < ActiveRecord::Migration
  def self.up
		#Be sure to change these settings for your initial admin user
=begin
    user = SiteUser.new
		user.login = "admin"
		user.email = APP_CONFIG['settings']['admin_email']
		user.password = "password"
		user.password_confirmation = "password"
				
    user.save

		role = Role.new
		#Admin role name should be "admin" for convenience
		role.name = "admin"
		role.save(false)
		admin_user = SiteUser.find_by_login("admin")
		admin_role = Role.find_by_name("admin")
		admin_user.activated_at = Time.now.utc
		admin_user.roles << admin_role

		admin_user.first_name = "admin user"
		admin_user.last_name = "DO NOT REMOVE"

		admin_user.save(false)

    # All registered users must have a party record in the system.
	    
    ind = Individual.new( :current_first_name => "Admin User",
      :current_last_name => "DO NOT REMOVE" )
	    
    ind.save
    ind.party.enterprise_identifier = '0'
    ind.party.save
	    
    puts ##########################################
    puts ind.party.id
	    					
    user.party_id = ind.party.id
    user.save(false)

=end

=begin
    user = SiteUser.new(:login => 'admin',
      :email => 'compass_admin@yourdomain.com',
      :name => "admin compass",
      :password => "password",
      :password_confirmation =>"password",
      :security_answer_1 => "answer1",
      :security_answer_2 => "answer2",
      :first_name=>"admin",
      :last_name=>"compass",
      :security_answer_1 => 'blah',
      :security_answer_2 => 'blah'
      )

    user.save

    role1 = Role.new
    #Admin role name should be "admin" for convenience
    role1.name = "admin"
    role1.save(false)

    role2 = Role.new
    #Admin role name should be "admin" for convenience
    role2.name = "agent"
    role2.save(false)


    admin_user = SiteUser.find_by_login("admin")
    admin_role = Role.find_by_name("admin")
    agent_role = Role.find_by_name("agent")

    admin_user.activated_at = Time.now.utc
    admin_user.roles << admin_role
    admin_user.roles << agent_role


    # All registered users must have a party record in the system.

    ind = Individual.new( :current_first_name => "Admin User",
      :current_last_name => "DO NOT REMOVE" )

    ind.save

    ind.party.enterprise_identifier = '0'
    ind.party.save

    puts ##########################################
    puts ind.party.id

    admin_user.party_id = ind.party.id
    admin_user.save(false)
=end
  end

  def self.down
=begin

   admin_user = User.find_by_login("admin")
    admin_role = Role.find_by_name("admin")
    if !admin_user.nil?
      admin_user.roles = []
      admin_user.save
      admin_user.destroy
    end

    admin_role.destroy unless admin_role.nil?

    ind = Individual.find_by_current_first_name("Admin User")
    ind.destroy unless ind.nil?
		
=end
  end
end
