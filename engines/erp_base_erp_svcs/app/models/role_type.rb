class RoleType < ActiveRecord::Base
  unloadable

  acts_as_nested_set
  acts_as_erp_type
  include TechServices::Utils::DefaultNestedSetMethods

  # For Rails 2.1: overrWide default of include_root_in_json
  # (the Ext.tree.TreeLoader cannot use the additional nesting)
  RoleType.include_root_in_json = false if RoleType.respond_to?(:include_root_in_json)
    
  has_many :party_roles
  has_many :parties, :through => :party_roles
end
