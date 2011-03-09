class PostalAddressChangeEventObserver < ActiveRecord::Observer
  observe :postal_address

  def after_save(address)
    create_change_event(address)
  end

  private

  def create_change_event(address)
    change_record = CommunicationEvent.new(nil)
    change_record.from_party = Party.find( address.contact.party_id )
    change_record.from_role = RoleType.find_by_internal_identifier( 'hvc_member')
    change_record.to_party = Party.find_by_enterprise_identifier('HCV')
    change_record.to_role = RoleType.find_by_internal_identifier('hvc')
    change_record.comm_evt_purpose_types << CommEvtPurposeType.find_by_description("Address Change Request")
    change_record.comm_evt_status = CommEvtStatus.find_by_internal_identifier('new')
    change_record.save
  end
  
end
