class WorkEffortIncremental < ActiveRecord::Migration
  def self.up
    #20100329161717_create_party_resource_availabilities.rb
    unless table_exists?(:party_resource_availabilities)
      create_table :party_resource_availabilities do |t|
        t.datetime :from_date
        t.datetime :to_date
        t.integer :party_id
        t.integer :party_resource_availability_type_id

        t.timestamps
      end
    end
    
    #20100329162305_create_party_resource_availability_types.rb
    unless table_exists?(:party_resource_availability_types)
      create_table :party_resource_availability_types do |t|
        t.string :description
        t.string :internal_identifier

        t.timestamps
      end
    end
    
    #20100405190813_change_work_requirement_type_column.rb
    if columns(:work_requirements).collect {|c| c.name}.include?('type')
      change_column :work_requirements, :type, :string
    end
      
    #20100408200336_update_work_effort_assignments.rb
    if columns(:work_effort_assignments).collect {|c| c.name}.include?('assigned_to')
      rename_column :work_effort_assignments, :assigned_to, :assigned_thru
    end
    
    #20100413204139_remove_nested_set_cols_from_work_req_work_eff_stat_types.rb
    if columns(:work_requirement_work_effort_status_types).collect {|c| c.name}.include?('parent_id')
      remove_column :work_requirement_work_effort_status_types, :parent_id
    end
    
    if columns(:work_requirement_work_effort_status_types).collect {|c| c.name}.include?('lft')
      remove_column :work_requirement_work_effort_status_types, :lft
    end
    
    if columns(:work_requirement_work_effort_status_types).collect {|c| c.name}.include?('rgt')
      remove_column :work_requirement_work_effort_status_types, :rgt
    end
    
    #20100423174700_rename_resource_avail_shorter.rb
    if columns(:party_resource_availabilities).collect {|c| c.name}.include?('party_resource_availability_type_id')
      rename_column :party_resource_availabilities, :party_resource_availability_type_id, :pra_type_id
    end
    
    #20100428132506_create_work_effort_indexes.rb
    if table_exists?(:work_efforts)    
      add_index :work_efforts, [:work_effort_record_id, :work_effort_record_type], :name => "work_effort_record_id_type"
      add_index :work_efforts, [:facility_type, :facility_id], :name => "facility"
      add_index :work_efforts, :work_effort_assignment_id
      add_index :work_efforts, :finished_at
    end

    if table_exists?(:work_effort_statuses)
      add_index :work_effort_statuses, :work_effort_status_type_id
      add_index :work_effort_statuses, :work_effort_id
    end
    
    if table_exists?(:party_resource_availabilities)
      add_index :party_resource_availabilities, :from_date
      add_index :party_resource_availabilities, :to_date
      add_index :party_resource_availabilities, :pra_type_id
      add_index :party_resource_availabilities, :party_id
    end
    
    if table_exists?(:work_effort_assignments)    
      add_index :work_effort_assignments, [:assigned_to_id, :assigned_to_type], :name => "assigned_to"
      add_index :work_effort_assignments, :assigned_from
      add_index :work_effort_assignments, :assigned_thru
    end
    
    if table_exists?(:work_effort_status_types)
      add_index :work_effort_status_types, :internal_identifier
      add_index :work_effort_status_types, :description
    end
    
    if table_exists?(:party_resource_availability_types)
      add_index :party_resource_availability_types, :internal_identifier
      add_index :party_resource_availability_types, :description
    end
    
    #20100413204139_remove_nested_set_cols_from_work_req_work_eff_stat_types.rb
    if columns(:work_requirement_work_effort_status_types).collect {|c| c.name}.include?('parent_id')
      remove_column :work_requirement_work_effort_status_types, :parent_id
    end
    if columns(:work_requirement_work_effort_status_types).collect {|c| c.name}.include?('lft')
      remove_column :work_requirement_work_effort_status_types, :lft
    end
    if columns(:work_requirement_work_effort_status_types).collect {|c| c.name}.include?('rgt')
      remove_column :work_requirement_work_effort_status_types, :rgt
    end
  end
  
  def self.down
    #20100329161717_create_party_resource_availabilities.rb
    if table_exists?(:party_resource_availabilities)
      drop_table :party_resource_availabilities
    end
    
    #20100329162305_create_party_resource_availability_types.rb
    if table_exists?(:party_resource_availabilities)
      drop_table :party_resource_availability_types
    end
    
    #20100405190813_change_work_requirement_type_column.rb
    # A change_column will fail once any char data is saved in type column
    # doing a remove and add drops all data in type, must be done if we want
    # to go back.
    unless columns(:work_requirements).collect {|c| c.name}.include?('type')
      remove_column :work_requirements, :type
      add_column    :work_requirements, :type, :integer
    end
    
    #20100413204139_remove_nested_set_cols_from_work_req_work_eff_stat_types.rb
    if table_exists?(:work_requirement_work_effort_status_types)
      unless columns(:work_requirement_work_effort_status_types).collect {|c| c.name}.include?('parent_id')
        add_column :work_requirement_work_effort_status_types, :parent_id, :integer
      end
      unless columns(:work_requirement_work_effort_status_types).collect {|c| c.name}.include?('lft')
        add_column :work_requirement_work_effort_status_types, :lft, :integer
      end
      unless columns(:work_requirement_work_effort_status_types).collect {|c| c.name}.include?('rgt')
        add_column :work_requirement_work_effort_status_types, :rgt, :integer
      end
    end
    #20100423174700_rename_resource_avail_shorter.rb
    unless columns(:work_requirement_work_effort_status_types).collect {|c| c.name}.include?('party_resource_availability_type_id')
      rename_column :party_resource_availabilities, :pra_type_id, :party_resource_availability_type_id
    end

    #20100428132506_create_work_effort_indexes.rb
    # Probably should be checking if the index exists also, otherwise this will
    # throw an exception or something - khallmar (08/23/2010)
    if table_exists?(:work_efforts)    
      remove_index :work_efforts, :name => "work_effort_record_id_type"
      remove_index :work_efforts, :name => "facility"
      remove_index :work_efforts, :work_effort_assignment_id
      remove_index :work_efforts, :finished_at
    end
    
    if table_exists?(:work_effort_statuses)    
      remove_index :work_effort_statuses, :work_effort_status_type_id
      remove_index :work_effort_statuses, :work_effort_id
    end
    
    if table_exists?(:party_resource_availabilities)    
      remove_index :party_resource_availabilities, :from_date
      remove_index :party_resource_availabilities, :to_date
      remove_index :party_resource_availabilities, :pra_type_id
      remove_index :party_resource_availabilities, :party_id
    end
    
    if table_exists?(:work_effort_assignments)    
      remove_index :work_effort_assignments, :name => "assigned_to"
      remove_index :work_effort_assignments, :assigned_from
      remove_index :work_effort_assignments, :assigned_thru
    end
    
    if table_exists?(:work_effort_status_types)    
      remove_index :work_effort_status_types, :internal_identifier
      remove_index :work_effort_status_types, :description
    end
    
    if table_exists?(:party_resource_availablity_types)    
      remove_index :party_resource_availablity_types, :internal_identifier
      remove_index :party_resource_availablity_types, :description
    end
  end
end
