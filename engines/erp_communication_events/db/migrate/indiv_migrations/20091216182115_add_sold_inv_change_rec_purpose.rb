class AddSoldInvChangeRecPurpose < ActiveRecord::Migration

  def self.up
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Insert or Update Sold Inventory"
    purpose_type.internal_identifier = "insert_update_sold_inventory"
    purpose_type.save
  end

  def self.down
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("insert_update_sold_inventory")
    purpose_type.destroy unless (purpose_type.nil?)
  end

end
