class BaseWorkEfforts < ActiveRecord::Migration
 
  def self.up

    ## work_efforts
    unless table_exists?(:work_efforts)
      create_table :work_efforts do |t|
        t.string   :description
        t.string   :type
        t.datetime :started_at
        t.datetime :finished_at
        t.integer  :projected_completion_time
        t.integer  :actual_completion_time

        t.timestamps

        #polymorphic columns
        t.integer  :facility_id
        t.string   :facility_type
        t.integer  :work_effort_record_id
        t.string   :work_effort_record_type

        #foreign keys
        t.integer  :work_effort_assignment_id
        t.integer  :projected_cost_id
        t.integer  :actual_cost_id

        #better nested set columns
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt
      end
    end

    ## work_requirements
    unless table_exists?(:work_requirements)
      create_table :work_requirements do |t|
        t.string :description
        t.string :type
        t.integer :projected_completion_time
        t.timestamps

        #polymorphic columns
        t.integer :work_requirement_record_id
        t.string  :work_requirement_record_type
        t.integer :facility_id
        t.string  :facility_type

        # foreign keys
        t.integer :cost_id

        #better nested set columns
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt
      end
    end
  
    ## work_requirement_work_effort_status_types
    unless table_exists?(:work_requirement_work_effort_status_types)
      create_table :work_requirement_work_effort_status_types do |t|
        t.timestamps

        #foreign keys
        t.integer :work_requirement_id
        t.integer :work_effort_status_type_id
        t.boolean :is_initial_status
      end
    end

    ## work_effort_statuses
    unless table_exists?(:work_effort_statuses)
      create_table :work_effort_statuses do |t|
        t.datetime :started_at
        t.datetime :finished_at
        t.integer :work_effort_id
        t.integer :work_effort_status_type_id

        t.timestamps
      end
    end

    ## work_effort_status_types
    unless table_exists?(:work_effort_status_types)
      create_table :work_effort_status_types do |t|
        t.string  :internal_identifier
        t.string  :description
        t.integer :next_status_id
        t.integer :previous_status_id

        t.timestamps
      end
    end

    ## work_effort_assignments
    unless table_exists?(:work_effort_assignments)
      create_table :work_effort_assignments do |t|
        t.datetime :assigned_at
        t.datetime :assigned_from
        t.datetime :assigned_thru
        t.datetime :unassigned_at

        #Polymorphic Columns
        t.integer :assigned_to_id
        t.string  :assigned_to_type
        t.integer :assigned_by_id
        t.string  :assigned_by_type

        t.timestamps
      end
    end

    ## valid_work_assignments
    unless table_exists?(:valid_work_assignments)
      create_table :valid_work_assignments do |t|
        t.integer :role_type_id
        t.integer :work_requirement_id

        t.timestamps
      end
    end

    ## valid_work_assignment_attributes
    unless table_exists?(:valid_work_assignment_attributes)
      create_table :valid_work_assignment_attributes do |t|
        t.integer :valid_work_assignment_id
        t.string  :name
        t.string  :type
        t.string  :value

        t.timestamps
      end
    end

    ## party_resource_availabilities
    unless table_exists?(:party_resource_availabilities)
      create_table :party_resource_availabilities do |t|
        t.datetime :from_date
        t.datetime :to_date
        t.integer :party_id
        t.integer :pra_type_id #:party_resource_availability_type_id is too long

        t.timestamps
      end
    end

    unless table_exists?(:party_resource_availability_types)
      create_table :party_resource_availability_types do |t|
        t.string :description
        t.string :internal_identifier

        t.timestamps
      end
    end

    ## costs
    unless table_exists?(:costs)
      create_table :costs do |t|
        t.integer :money_id
        t.timestamps
      end
    end
    
  end

  def self.down
    # Drop all tables, including those that were originally created then deleted
    [
      # Old tables deleted and no longer used
      :work_requirement_assignabilities,
      # Currently used tables
      :category_classifications, :categories, :work_requirement_assignability_attributes,
      :valid_work_assignments, :work_effort_assignments, :work_effort_status_types,
      :work_effort_statuses, :work_requirement_work_effort_status_types,
      :work_requirements, :work_efforts, :party_resource_availabilities, :party_resource_availability_types,
      :costs
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end

  end
end
