class AuditLogItemType < ActiveRecord::Base
  acts_as_nested_set
	include TechServices::Utils::DefaultNestedSetMethods
	acts_as_erp_type

  has_many :audit_log_items
end
