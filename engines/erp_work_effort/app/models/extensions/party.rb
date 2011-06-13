Party.class_eval do

  has_many :party_resource_availabilities, :class_name => 'PartyResourceAvailability', :dependent => :destroy

end
