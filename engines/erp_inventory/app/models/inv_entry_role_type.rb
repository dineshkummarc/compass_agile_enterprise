class InvEntryRoleType < ActiveRecord::Base

  acts_as_nested_set
  include TechServices::Utils::DefaultNestedSetMethods

  # For Rails 2.1: override default of include_root_in_json
  # (the Ext.tree.TreeLoader cannot use the additional nesting)
  InvEntryRoleType.include_root_in_json = false if InvEntryRoleType.respond_to?(:include_root_in_json)   
  
end
