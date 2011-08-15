class AuditLogItem < ActiveRecord::Base
  belongs_to :audit_log_item_type
  belongs_to :audit_log
end
