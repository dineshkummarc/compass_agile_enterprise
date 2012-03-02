class SetupAuditLogTypes
  
  def self.up
    application_alt = AuditLogType.create(:description => 'Application', :internal_identifier => 'application')

    [
      {:description => 'Custom Message', :internal_identifier => 'custom_message'},
      {:description => 'Successful Logout', :internal_identifier => 'successful_logout'},
      {:description => 'Successful Login', :internal_identifier => 'successful_login'},
      {:description => 'Accessed Area', :internal_identifier => 'accessed_area'},
      {:description => 'Session Timeout', :internal_identifier => 'session_timeout'}
    ].each do |alt_hash|
        AuditLogType.create(alt_hash).move_to_child_of(application_alt)
    end
  end
  
  def self.down
    AuditLogType.destroy_all
  end

end
