Party.class_eval do
  has_many :resource_availabilities, :class_name => 'PartyResourceAvailability', :dependent => :destroy
end
