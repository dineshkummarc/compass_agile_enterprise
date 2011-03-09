class AddMoreChangeRecPurposes < ActiveRecord::Migration
  def self.up
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Insert or Update Postal Addresses"
    purpose_type.internal_identifier = "insert_update_postal_addresses"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Insert or Update Email Addresses"
    purpose_type.internal_identifier = "insert_update_email_addresses"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Insert or Update Phone Numbers"
    purpose_type.internal_identifier = "insert_update_phone_numbers"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Insert or Update Individual Name"
    purpose_type.internal_identifier = "insert_update_name"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Insert or Update Individual"
    purpose_type.internal_identifier = "insert_update_individual"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Insert or Update Points"
    purpose_type.internal_identifier = "insert_update_points"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Insert or Update Contract"
    purpose_type.internal_identifier = "insert_update_contract"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Insert or Update Registry Collection"
    purpose_type.internal_identifier = "insert_update_registry_collection"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Insert or Update PCR"
    purpose_type.internal_identifier = "insert_update_pcr"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Insert or Update Co Owner"
    purpose_type.internal_identifier = "insert_update_co_owner"
    purpose_type.save

    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Delete Postal Addresses"
    purpose_type.internal_identifier = "delete_postal_addresses"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Delete Email Addresses"
    purpose_type.internal_identifier = "delete_email_addresses"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Delete Phone Numbers"
    purpose_type.internal_identifier = "delete_phone_numbers"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Delete Individual Name"
    purpose_type.internal_identifier = "delete_name"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Delete Individual"
    purpose_type.internal_identifier = "delete_individual"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Delete Points"
    purpose_type.internal_identifier = "delete_points"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Delete Contract"
    purpose_type.internal_identifier = "delete_contract"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Delete Registry Collection"
    purpose_type.internal_identifier = "delete_registry_collection"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Delete PCR"
    purpose_type.internal_identifier = "delete_pcr"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Delete Co Owner"
    purpose_type.internal_identifier = "delete_co_owner"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Change Request - Delete Sold Inventory"
    purpose_type.internal_identifier = "delete_sold_inventory"
    purpose_type.save

  end

  def self.down
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("insert_update_postal_addresses")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("insert_update_email_addresses")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("insert_update_phone_numbers")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("insert_update_name")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("insert_update_individual")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("insert_update_points")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("insert_update_contract")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("insert_update_registry_collection")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("insert_update_pcr")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("insert_update_co_owner")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("delete_postal_addresses")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("delete_email_addresses")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("delete_phone_numbers")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("delete_name")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("delete_individual")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("delete_points")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("delete_contract")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("delete_registry_collection")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("delete_pcr")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("delete_co_owner")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("delete_sold_inventory")
    purpose_type.destroy unless (purpose_type.nil?)
  end
end
