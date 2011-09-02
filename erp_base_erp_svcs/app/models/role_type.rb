class RoleType < ActiveRecord::Base
  unloadable
  acts_as_nested_set
  acts_as_erp_type
    
  has_many :party_roles
  has_many :parties, :through => :party_roles
end
