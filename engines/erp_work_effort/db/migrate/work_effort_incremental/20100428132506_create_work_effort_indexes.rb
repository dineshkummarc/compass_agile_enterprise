class CreateWorkEffortIndexes < ActiveRecord::Migration
  def self.up
    add_index :work_efforts, [:work_effort_record_id, :work_effort_record_type], :name => "work_effort_record_id_type"
    add_index :work_efforts, [:facility_type, :facility_id], :name => "facility"
    add_index :work_efforts, :work_effort_assignment_id
    add_index :work_efforts, :finished_at

    add_index :work_effort_statuses, :work_effort_status_type_id
    add_index :work_effort_statuses, :work_effort_id

    add_index :party_resource_availabilities, :from_date
    add_index :party_resource_availabilities, :to_date
    add_index :party_resource_availabilities, :pra_type_id
    add_index :party_resource_availabilities, :party_id

    add_index :work_effort_assignments, [:assigned_to_id, :assigned_to_type], :name => "assigned_to"
    add_index :work_effort_assignments, :assigned_from
    add_index :work_effort_assignments, :assigned_thru

    add_index :work_effort_status_types, :internal_identifier
    add_index :work_effort_status_types, :description

    add_index :party_resource_availability_types, :internal_identifier
    add_index :party_resource_availability_types, :description
  end

  def self.down
    remove_index :work_efforts, :name => "work_effort_record_id_type"
    remove_index :work_efforts, :name => "facility"
    remove_index :work_efforts, :work_effort_assignment_id
    remove_index :work_efforts, :finished_at

    remove_index :work_effort_statuses, :work_effort_status_type_id
    remove_index :work_effort_statuses, :work_effort_id

    remove_index :party_resource_availabilities, :from_date
    remove_index :party_resource_availabilities, :to_date
    remove_index :party_resource_availabilities, :pra_type_id
    remove_index :party_resource_availabilities, :party_id

    remove_index :work_effort_assignments, :name => "assigned_to"
    remove_index :work_effort_assignments, :assigned_from
    remove_index :work_effort_assignments, :assigned_thru

    remove_index :work_effort_status_types, :internal_identifier
    remove_index :work_effort_status_types, :description

    remove_index :party_resource_availablity_types, :internal_identifier
    remove_index :party_resource_availablity_types, :description
  end
end
