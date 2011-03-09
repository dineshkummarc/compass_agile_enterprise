class EmailAddressChangeEventObserver < ActiveRecord::Observer
  observe :email_address

  def after_save(email)
    create_change_event(email)
  end

  private

  def create_change_event(email)    
    change_record = CommunicationEvent.new(nil)
    change_record.from_party = Party.find( email.contact.party_id )
    change_record.from_role = RoleType.find_by_internal_identifier( 'hvc_member')
    change_record.to_party = Party.find_by_enterprise_identifier('HCV')
    change_record.to_role = RoleType.find_by_internal_identifier('hvc')
    change_record.comm_evt_purpose_types << CommEvtPurposeType.find_by_description("Email Change Request")
    change_record.comm_evt_status = CommEvtStatus.find_by_internal_identifier('new')
    change_record.save
  end
  
end