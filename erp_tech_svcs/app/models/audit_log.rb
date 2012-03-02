class AuditLog < ActiveRecord::Base

  validates :party_id, :presence => {:message => 'Party cannot be blank'}
  validates :description, :presence => {:message => 'Description cannot be blank'}
  validates :audit_log_type, :presence => {:message => 'Audit Log Type cannot be blank'}

  belongs_to :audit_log_type
  has_many   :audit_log_items
  belongs_to :event_record, :polymorphic => true

  class << self
    def custom_application_log_message(party, msg)
      self.create(
        :party_id => party.id,
        :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('application','custom_message'),
        :description => "#{party.description}: #{msg}"
      )
    end

    def party_logout(party)
      self.create(
        :party_id => party.id,
        :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('application','successful_logout'),
        :description => "#{party.description} has logged out"
      )
    end

    def party_login(party)
      self.create(
        :party_id => party.id,
        :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('application','successful_login'),
        :description => "#{party.description} has logged in"
      )
    end

    def party_access(party, url)
      self.create(
        :party_id => party.id,
        :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('application','accessed_area'),
        :description => "#{party.description} has accessed area #{url}"
      )
    end

    def party_failed_access(party, url)
      self.create(
        :party_id => party.id,
        :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('application','accessed_area'),
        :description => "#{party.description} has tried to access a restricted area #{url}"
      )
    end

    def party_session_timeout(party)
      self.create(
        :party_id => party.id,
        :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('application','session_timeout'),
        :description => "#{party.description} session has expired"
      )
    end
  end
end
