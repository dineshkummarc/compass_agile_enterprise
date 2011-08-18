class User < ActiveRecord::Base
  belongs_to :party
  attr_accessible :roles
  has_and_belongs_to_many :roles
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable, :timeoutable, :confirmable and :activatable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :login, :username
  attr_accessor :login
  
  def contains_role?(r)
    self.roles.each do |this_role|
      if(this_role.internal_identifier==r)
        return true
      end
    end
    return false
  end

  def contains_roles?(passed_roles)
    passed_roles.each do |passed_role|
      if contains_role?(passed_role)
        return true
      end
    end
    return false
  end

  def add_role(r)
    found = false
    self.roles.each do |role|
      if role.internal_identifier == r
        found = true
      end
    end
    self.roles << Role.find_by_internal_identifier(r) if found == false
  end
  
  protected

   def self.find_for_database_authentication(warden_conditions)
     conditions = warden_conditions.dup
     login = conditions.delete(:login)
     where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
   end
  
end
