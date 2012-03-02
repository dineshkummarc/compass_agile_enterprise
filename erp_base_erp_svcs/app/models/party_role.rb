class PartyRole < ActiveRecord::Base
    belongs_to :party, :class_name => "Party", :foreign_key => "party_id"
    belongs_to :role_type, :class_name => "RoleType", :foreign_key => "role_type_id"

    def to_label
        self.role_type.description
    end
end