class AuditLog < ActiveRecord::Base

  validates_presence_of :party_id
  validates_presence_of :description
  validates_presence_of :audit_log_type

  belongs_to :audit_log_type
  has_many   :audit_log_items
  belongs_to :event_record, :polymorphic => true

  def user_id_name
   u= Party.find(:first, :conditions=>"id = #{user_id}")
   if(u!=nil)
     return u.user.login
   else
     return "cannot find user #{user_id}"
   end
  end

  def AuditLog.custom_log_message(party, msg)
    AuditLog.create(
      :party_id => party.id,
      :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('core','custom_message'),
      :description => "#{party.description}: #{msg}"
    )
  end

  def AuditLog.party_logout(party)
    AuditLog.create(
      :party_id => party.id,
      :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('core','sucessful_logout'),
      :description => "#{party.description} has logged out"
    )
  end

  def AuditLog.party_login(party)
    AuditLog.create(
      :party_id => party.id,
      :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('core','successful_login'),
      :description => "#{party.description} has logged in"
    )
  end

  def AuditLog.party_access(party, url)
    AuditLog.create(
      :party_id => party.id,
      :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('core','accessed_area'),
      :description => "#{party.description} has accessed area #{url}"
    )
  end

  def AuditLog.party_failed_access(party, url)
    AuditLog.create(
      :party_id => party.id,
      :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('core','accessed_area'),
      :description => "#{party.description} has tried to access a restricted area #{url}"
    )
  end

  def AuditLog.party_session_timeout(party)
    AuditLog.create(
      :party_id => party.id,
      :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('core','session_timeout'),
      :description => "#{party.description} session has expired"
    )
  end
end
