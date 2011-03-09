class AddReservationChargesChangeRecordPurpose < ActiveRecord::Migration
  def self.up
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("insert_update_reservation_charges")
    if purpose_type.nil?
      purpose_type = CommEvtPurposeType.new
      purpose_type.description = "Change Request - Insert or Update Reservation Charges"
      purpose_type.internal_identifier = "insert_update_reservation_charges"
      purpose_type.save
    end
  end

  def self.down
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("insert_update_reservation_charges")
    purpose_type.destroy unless (purpose_type.nil?)
  end
end
