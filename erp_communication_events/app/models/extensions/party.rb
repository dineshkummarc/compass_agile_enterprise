Party.class_eval do

  has_many :from_communication_events, :class_name => 'CommunicationEvent', :foreign_key => 'party_id_from'
  has_many :to_communication_events, :class_name => 'CommunicationEvent', :foreign_key => 'party_id_to'

end
