class RelationshipType < ActiveRecord::Base

    acts_as_nested_set
    acts_as_erp_type
    include TechServices::Utils::DefaultNestedSetMethods

    # For Rails 2.1: override default of include_root_in_json
    # (the Ext.tree.TreeLoader cannot use the additional nesting)
    RelationshipType.include_root_in_json = false if RoleType.respond_to?(:include_root_in_json)

    belongs_to :valid_from_role, :class_name => "RoleType", :foreign_key => "valid_from_role_type_id"
    belongs_to :valid_to_role,   :class_name => "RoleType", :foreign_key => "valid_to_role_type_id"
    
end
