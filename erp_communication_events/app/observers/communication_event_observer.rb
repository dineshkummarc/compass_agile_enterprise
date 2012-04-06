class CommunicationEventObserver < ActiveRecord::Observer

	def after_commit_on_create(comm_event)
    Rails.logger.debug "CommunicationEventObserver - calling after_commit_on_create: outside transaction - #{comm_event.connection.outside_transaction?}"
    unless comm_event.comm_evt_purpose_types.first.description.include?("Change Request")
      begin
        CommunicationEventMailer.contact_notification(comm_event).deliver
      rescue Exception => e
        system_user = Party.find_by_description('Compass AE')
        AuditLog.custom_application_log_message(system_user, e)
      end
    end
  end

end