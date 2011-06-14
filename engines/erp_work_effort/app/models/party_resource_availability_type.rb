class PartyResourceAvailabilityType < ActiveRecord::Base
  has_many :party_resource_availabilities

  def self.iid(internal_identifier)
  	 	self.find( :first, :conditions => ['internal_identifier = ?', internal_identifier] )
  end
end
