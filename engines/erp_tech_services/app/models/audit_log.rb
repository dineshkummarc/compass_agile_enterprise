class AuditLog < ActiveRecord::Base

  validates_presence_of :application_id
  validates_presence_of :party_id
  validates_presence_of :description

  def user_id_name
   u= Party.find(:first, :conditions=>"id = #{user_id}")
   if(u!=nil)
     return u.user.login
   else
     return "cannot find user #{user_id}"
   end
  end

  def AuditLog.custom_log_message(party, msg)
    AuditLog.create(:application_id => Constants::AUDITING[:core][:application_id],
      :party_id => party.id,
      :event_id => Constants::AUDITING[:core][:custom_message],
      :description => "#{party.description}: #{msg}"
    )
  end

  def AuditLog.party_logout(party)
    AuditLog.create(:application_id => Constants::AUDITING[:core][:application_id],
      :party_id => party.id,
      :event_id => Constants::AUDITING[:core][:sucessful_logout],
      :description => "#{party.description} has logged out"
    )
  end

  def AuditLog.party_login(party)
    AuditLog.create(:application_id => Constants::AUDITING[:core][:application_id],
      :party_id => party.id,
      :event_id => Constants::AUDITING[:core][:successful_login],
      :description => "#{party.description} has logged in"
    )
  end

  def AuditLog.party_registration_complete(party)
    AuditLog.create(:application_id => Constants::AUDITING[:hicv][:application_id],
      :party_id => party.id,
      :event_id => Constants::AUDITING[:hicv][:registered],
      :description => "#{party.description} has completed registration"
    )
  end

  def AuditLog.party_activation_expired(party)
    AuditLog.create(:application_id => Constants::AUDITING[:hicv][:application_id],
      :party_id => party.id,
      :event_id => Constants::AUDITING[:hicv][:activation_expired],
      :description => "#{party.description} has expired activation code"
    )
  end

  def AuditLog.party_activation_already_registered(party)
    AuditLog.create(:application_id => Constants::AUDITING[:hicv][:application_id],
      :party_id => party.id,
      :event_id => Constants::AUDITING[:hicv][:activation_already_registered],
      :description => "#{party.description} has tried to activate and is already registered."
    )
  end

  def AuditLog.party_activation_another_registered(party)
    AuditLog.create(:application_id => Constants::AUDITING[:hicv][:application_id],
      :party_id => party.id,
      :event_id => Constants::AUDITING[:hicv][:activation_another_registered],
      :description => "#{party.description} has tried to activate against someone elses already activated account."
    )
  end

  def AuditLog.insufficient_validation_data(party)
    AuditLog.create(:application_id => Constants::AUDITING[:hicv][:application_id],
      :party_id => party.id,
      :event_id => Constants::AUDITING[:hicv][:insufficient_validation_data],
      :description => "#{party.description} has tried to activate, but has insufficient validation data."
    )
  end

  def AuditLog.initiate_password_reset(party)
    AuditLog.create(:application_id => Constants::AUDITING[:hicv][:application_id],
      :party_id => party.id,
      :event_id => Constants::AUDITING[:hicv][:initiate_password_reset],
      :description => "#{party.description} has initiated a password reset"
    )
  end

  def AuditLog.party_reset_password(party)
    AuditLog.create(:application_id => Constants::AUDITING[:hicv][:application_id],
      :party_id => party.id,
      :event_id => Constants::AUDITING[:hicv][:reset_password],
      :description => "#{party.description} has reset their password"
    )
  end

  def AuditLog.account_locked(party)
    AuditLog.create(:application_id => Constants::AUDITING[:hicv][:application_id],
      :party_id => party.id,
      :event_id => Constants::AUDITING[:hicv][:account_locked],
      :description => "#{party.description} has failed security questions too many times and account is locked."
    )
  end

  def AuditLog.party_session_timeout(party)
    AuditLog.create(:application_id => Constants::AUDITING[:hicv][:application_id],
      :party_id => party.id,
      :event_id => Constants::AUDITING[:hicv][:session_timeout],
      :description => "#{party.description} session has expired"
    )
  end

  def AuditLog.party_failed_security_question(party)
    AuditLog.create(:application_id => Constants::AUDITING[:hicv][:application_id],
      :party_id => party.id,
      :event_id => Constants::AUDITING[:hicv][:failed_security_question],
      :description => "#{party.description} failed scurity questions answer"
    )
  end

  def AuditLog.party_access(party, url)
    AuditLog.create(:application_id => Constants::AUDITING[:core][:application_id],
      :party_id => party.id,
      :event_id => Constants::AUDITING[:core][:accessed_area],
      :description => "#{party.description} has accessed area #{url}"
    )
  end

  def AuditLog.party_failed_access(party, url)
    AuditLog.create(:application_id => Constants::AUDITING[:core][:application_id],
      :party_id => party.id,
      :event_id => Constants::AUDITING[:core][:accessed_area],
      :description => "#{party.description} has tried to accessed a restricted area #{url}"
    )
  end
end
