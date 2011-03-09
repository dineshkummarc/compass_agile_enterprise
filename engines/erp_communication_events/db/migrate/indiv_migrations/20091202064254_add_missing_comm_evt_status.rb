class AddMissingCommEvtStatus < ActiveRecord::Migration
  COMM_EVENT_PURPOSE_TYPE_ADDRESS = 'Address Change Request'
  COMM_EVENT_PURPOSE_TYPE_PHONE = 'Phone Number Change Request'
  COMM_EVENT_PURPOSE_TYPE_EMAIL = 'Email Change Request'
  ADDRESS_CHANGE_EVENT_TYPES = ["#{COMM_EVENT_PURPOSE_TYPE_ADDRESS}", "#{COMM_EVENT_PURPOSE_TYPE_PHONE}", "#{COMM_EVENT_PURPOSE_TYPE_EMAIL}"]

  def self.up
      events = CommunicationEvent.find(:all,
                                       :include => [:comm_evt_status, :comm_evt_purpose_types],
                                       :conditions => ["status_type_id is null " <<
                                                       " and comm_evt_purpose_types.description in (?)", ADDRESS_CHANGE_EVENT_TYPES])
      puts "Updating #{events.size} records"
      events.each do |event|
        event.comm_evt_status = CommEvtStatus.find_by_internal_identifier('new')
        puts "Added comm_evt_status to communication_event id: #{event.id}"
        event.save
      end
  end

  def self.down
  end
end
