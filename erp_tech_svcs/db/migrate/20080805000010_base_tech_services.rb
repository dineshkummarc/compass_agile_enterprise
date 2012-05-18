class BaseTechServices < ActiveRecord::Migration
  def self.up
    unless table_exists?(:users)
      # Create the users table
      create_table :users do |t|
        t.string :username
        t.string :email
        t.references :party
        t.string :type
        t.string :salt, :default => nil
        t.string :crypted_password, :default => nil

        #activity logging
        t.datetime :last_login_at, :default => nil
        t.datetime :last_logout_at, :default => nil
        t.datetime :last_activity_at, :default => nil

        #brute force protection
        t.integer :failed_logins_count, :default => 0
        t.datetime :lock_expires_at, :default => nil

        #remember me
        t.string :remember_me_token, :default => nil
        t.datetime :remember_me_token_expires_at, :default => nil

        #reset password
        t.string :reset_password_token, :default => nil
        t.datetime :reset_password_token_expires_at, :default => nil
        t.datetime :reset_password_email_sent_at, :default => nil
      
        #user activation
        t.string :activation_state, :default => nil
        t.string :activation_token, :default => nil
        t.datetime :activation_token_expires_at, :default => nil

        t.string :security_question_1
        t.string :security_answer_1
        t.string :security_question_2
        t.string :security_answer_2

        t.timestamps
      end
      add_index :users, :email, :unique => true
      add_index :users, :username, :unique => true
      add_index :users, [:last_logout_at, :last_activity_at], :name => 'activity_idx'
      add_index :users, :remember_me_token
      add_index :users, :reset_password_token
      add_index :users, :activation_token
    
    end

    unless table_exists?(:roles)
      # create the roles table
      create_table :roles do |t|
        t.column :description, :string
        t.column :internal_identifier, :string
        t.column :external_identifier, :string
        t.column :external_id_source, :string
        
        t.timestamps
      end
    end

    unless table_exists?(:sessions)
      # Create sessions table
      create_table :sessions do |t|
        t.string :session_id, :null => false
        t.text :data
        t.timestamps
      end
      add_index :sessions,      :session_id
      add_index :sessions,      :updated_at
    end

    unless table_exists?(:audit_logs)
      # Create audit_logs
      create_table   :audit_logs do |t|
        t.string     :application
        t.string     :description
        t.integer    :party_id
        t.text       :additional_info
        t.references :audit_log_type

        #polymorphic columns
        t.references :event_record, :polymorphic => true

        t.timestamps
      end
      add_index :audit_logs, :party_id
      add_index :audit_logs, [:event_record_id, :event_record_type], :name => 'event_record_index'
    end

    unless table_exists?(:audit_log_types)
      # Create audit_logs
      create_table :audit_log_types do |t|
        t.string :description
        t.string :error_code
        t.string :comments
        t.string :internal_identifier
        t.string :external_identifier
        t.string :external_id_source

        #better nested set columns
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        t.timestamps
      end
    end

    unless table_exists?(:audit_log_items)
      # Create audit_log_items
      create_table   :audit_log_items do |t|
        t.references :audit_log
        t.references :audit_log_item_type
        t.string     :audit_log_item_value
        t.string     :description

        t.timestamps
      end
    end

    unless table_exists?(:audit_log_item_types)
      # Create audit_log_item_types
      create_table   :audit_log_item_types do |t|
        t.string :internal_identifier
        t.string :external_identifier
        t.string :external_id_source
        t.string :description
        t.string :comments

        #better nested set columns
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        t.timestamps
      end
    end
    
    unless table_exists?(:secured_models)
      create_table :secured_models do |t|
        t.references :secured_record, :polymorphic => true
        
        t.timestamps
      end
      add_index :secured_models, [:secured_record_id, :secured_record_type], :name => 'secured_record_idx'
    end

    unless table_exists?(:roles_secured_models)
      create_table :roles_secured_models, :id => false do |t|
        t.references :secured_model
        t.references :role

        t.timestamps
      end
      add_index :roles_secured_models, :secured_model_id
      add_index :roles_secured_models, :role_id
    end

    unless table_exists?(:file_assets)
      create_table :file_assets do |t|
        t.references :file_asset_holder, :polymorphic => true
        t.string :type
        t.string :name
        t.string :directory
        t.string :data_file_name
        t.string :data_content_type
        t.integer :data_file_size
        t.datetime :data_updated_at

        t.timestamps
      end
      add_index :file_assets, :type
      add_index :file_assets, [:file_asset_holder_id, :file_asset_holder_type], :name => 'file_asset_holder_idx'
      add_index :file_assets, :name
      add_index :file_assets, :directory
    end
	
    unless table_exists?(:delayed_jobs)
      create_table :delayed_jobs, :force => true do |table|
        table.integer  :priority, :default => 0      # Allows some jobs to jump to the front of the queue
        table.integer  :attempts, :default => 0      # Provides for retries, but still fail eventually.
        table.text     :handler                      # YAML-encoded string of the object that will do work
        table.text     :last_error                   # reason for last failure (See Note below)
        table.datetime :run_at                       # When to run. Could be Time.zone.now for immediately, or sometime in the future.
        table.datetime :locked_at                    # Set when a client is working on this object
        table.datetime :failed_at                    # Set when all retries have failed (actually, by default, the record is deleted instead)
        table.string   :locked_by                    # Who is working on this object (if locked)
        table.string   :queue
        table.timestamps
      end
      add_index :delayed_jobs, [:priority, :run_at], :name => 'delayed_jobs_priority'
    end

    unless table_exists?(:capable_models)
      # create the roles table
      create_table :capable_models do |t|
        t.references :capable_model_record, :polymorphic => true

        t.timestamps
      end

      add_index :capable_models, [:capable_model_record_id, :capable_model_record_type], :name => 'capable_model_record_idx'
    end

    unless table_exists?(:capability_types)
      # create the roles table
      create_table :capability_types do |t|
        t.string :internal_identifier
        t.string :description
        t.timestamps
      end
    end

    unless table_exists?(:capabilities)
      # create the roles table
      create_table :capabilities do |t|
        t.string :resource
        t.references :capability_type
        t.timestamps
      end

      add_index :capabilities, :capability_type_id
    end

    unless table_exists?(:capabilities_capable_models)
      # create the roles table
      create_table :capabilities_capable_models, :id => false do |t|
        t.references :capable_model
        t.references :capability
        t.timestamps
      end

      add_index :capabilities_capable_models, :capable_model_id
      add_index :capabilities_capable_models, :capability_id
    end

  end

  def self.down
    # check that each table exists before trying to delete it.
    [
      :audit_logs, :sessions, :simple_captcha_data,
      :capable_models, :capability_types, :capabilities,:capabilities_capable_models,
      :roles_users, :roles, :audit_log_items, :audit_log_item_types,
      :users, :secured_models, :roles_secured_models, :file_assets, :delayed_jobs
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end
end
