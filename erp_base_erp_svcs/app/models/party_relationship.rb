class PartyRelationship < ActiveRecord::Base

    belongs_to :from_party, :class_name => "Party",   :foreign_key => "party_id_from"
    belongs_to :to_party,   :class_name => "Party",   :foreign_key => "party_id_to"

    belongs_to :from_role, :class_name => "RoleType", :foreign_key => "role_type_id_from"
    belongs_to :to_role,   :class_name => "RoleType", :foreign_key => "role_type_id_to"
  
    belongs_to :relationship_type, :class_name => "RelationshipType"

end
