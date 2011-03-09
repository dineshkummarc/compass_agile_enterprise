class AddChangeRecPurposes < ActiveRecord::Migration
  def self.up
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Reload Individual Change Request"
    purpose_type.internal_identifier = "reload_individual"
    purpose_type.save
    purpose_type = CommEvtPurposeType.new
    purpose_type.description = "Reload Points Change Request"
    purpose_type.internal_identifier = "reload_points"
    purpose_type.save
  end

  def self.down
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("reload_individual")
    purpose_type.destroy unless (purpose_type.nil?)
    purpose_type = CommEvtPurposeType.find_by_internal_identifier("reload_points")
    purpose_type.destroy unless (purpose_type.nil?)
  end
end
