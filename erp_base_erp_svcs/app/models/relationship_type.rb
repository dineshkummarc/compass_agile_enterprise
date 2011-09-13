class RelationshipType < ActiveRecord::Base
    acts_as_nested_set
    include ErpTechSvcs::Utils::DefaultNestedSetMethods
    acts_as_erp_type
    belongs_to :valid_from_role, :class_name => "RoleType", :foreign_key => "valid_from_role_type_id"
    belongs_to :valid_to_role,   :class_name => "RoleType", :foreign_key => "valid_to_role_type_id"
    
end
