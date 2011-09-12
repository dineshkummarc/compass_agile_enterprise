Party.class_eval do

  has_many :agreement_party_roles
  has_many :agreements, :through => :agreement_party_roles, :dependent => :destroy

end
