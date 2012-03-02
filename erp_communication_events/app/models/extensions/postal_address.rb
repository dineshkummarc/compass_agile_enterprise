PostalAddress.class_eval do

  has_many :from_communication_events, :class_name => 'CommunicationEvent', :as => 'from_contact_mechanism'
  has_many :to_communication_events, :class_name => 'CommunicationEvent', :as => 'to_contact_mechanism'

end
