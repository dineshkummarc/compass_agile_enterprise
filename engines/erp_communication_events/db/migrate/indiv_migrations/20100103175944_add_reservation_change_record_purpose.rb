class AddReservationChangeRecordPurpose < ActiveRecord::Migration
  def self.up
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Insert or Update Reservation"
    purpose_type.internal_identifier = "insert_update_reservation"
    purpose_type.save
  end

  def self.down
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("insert_update_reservation")
    purpose_type.destroy unless (purpose_type.nil?)
  end
end
