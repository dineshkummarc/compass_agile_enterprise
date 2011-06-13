class ContactPurpose < ActiveRecord::Base

    acts_as_nested_set
    include TechServices::Utils::DefaultNestedSetMethods
    acts_as_erp_type

    # For Rails 2.1: override default of include_root_in_json
    # (the Ext.tree.TreeLoader cannot use the additional nesting)
    ContactPurpose.include_root_in_json = false if ContactPurpose.respond_to?(:include_root_in_json)
    
    has_and_belongs_to_many :contacts
end
