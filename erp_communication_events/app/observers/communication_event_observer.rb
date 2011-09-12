class CommunicationEventObserver < ActiveRecord::Observer

	def after_commit_on_create(comm_event)
    ErpTechSvcs::CompassLogger.debug "CommunicationEventObserver - calling after_commit_on_create: outside transaction - #{comm_event.connection.outside_transaction?}"
    unless comm_event.comm_evt_purpose_types.first.description.include?("Change Request")
      CommunicationEventMailer.deliver_contact_notification(comm_event)
    end
  end

end