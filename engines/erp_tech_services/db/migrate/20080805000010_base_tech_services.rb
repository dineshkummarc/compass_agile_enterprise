class BaseTechServices < ActiveRecord::Migration
  def self.up
    unless table_exists?(:users)
      # Create the users table
      create_table :users, :force => true do |t|
		  	t.column :type,     								  :string
        t.column :login,                      :string, :limit => 40
        t.column :name,                       :string, :limit => 100, :default => '', :null => true
        t.column :email,                      :string, :limit => 100
        t.column :crypted_password,           :string, :limit => 40
        t.column :salt,                       :string, :limit => 40
        t.column :created_at,                 :datetime
        t.column :updated_at,                 :datetime
        t.column :remember_token,             :string, :limit => 40
        t.column :remember_token_expires_at,  :datetime
        t.column :activation_code,            :string, :limit => 40
        t.column :activated_at,               :datetime
        t.column :activation_code_expires_at, :datetime
 	      t.column :password_reset_code,        :string, :limit => 40
        t.column :enabled,                    :boolean,               :default => true   
	      t.column :identity_url,							  :string
	      t.column :invitation_id,						  :integer
	      t.column :invitation_limit, 				  :integer
	      t.column :party_id,                   :integer

	      # merge in add_security_questions_add_and_mist_to_user migration
        t.column :club_number,          :string
        t.column :owner_number,         :string
        t.column :dob,                  :date
        t.column :ssn_last_four,        :string

        t.column :salutation,           :string
        t.column :first_name,           :string
        t.column :last_name,            :string

        t.column :street_address,       :string
        t.column :city,                 :string
        t.column :state_province,       :string
        t.column :postal_code,          :string
        t.column :country,              :string
        t.column :phone,                :string

        t.column :security_question_1,  :string
        t.column :security_answer_1,    :string

        t.column :security_question_2,  :string
        t.column :security_answer_2,    :string  

        # merge in add_password_lock_count_column migration
	      t.column :lock_count,           :integer,     :default => 0
      end
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

    unless table_exists?(:roles_users)
      # generate the join table
      create_table :roles_users, :id => false do |t|
        t.integer :role_id, :user_id
      end
    end

    unless table_exists?(:logged_exceptions)
      # add exceptions table
      create_table :logged_exceptions, :force => true do |t|
        t.column :exception_class, :string
        t.column :controller_name, :string
        t.column :action_name,     :string
        t.column :message,         :text
        t.column :backtrace,       :text
        t.column :environment,     :text
        t.column :request,         :text
        t.column :created_at,      :datetime
      end
    end

    unless table_exists?(:four_oh_fours)
      # Create four_oh_fours table
      create_table :four_oh_fours do |t|
        t.string  :url,           :referer
        t.integer :count,         :default => 0
        t.string  :remote_address
        t.timestamps
      end
    end

    unless table_exists?(:user_failures)
      # Create user_failures
      create_table :user_failures do |t|
        t.string :remote_ip, :http_user_agent, :failure_type, :username
        t.integer :count, :default => 0
        t.timestamps
      end
    end

    unless table_exists?(:simple_captcha_data)
      # Create simple_captcha_data
      create_table :simple_captcha_data do |t|
        t.string :key,    :limit => 40
        t.string :value,  :limit => 6
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
    end

    unless table_exists?(:security_questions)
      # Create security questions table
      create_table :security_questions do |t|
        t.string :question
        t.timestamps
      end
    end

    unless table_exists?(:audit_logs)
      # Create audit_logs
      create_table   :audit_logs do |t|
        t.string     :application
        t.string     :descriptio
        t.integer    :party_id
        t.text       :additional_info
        t.references :audit_log_type

        #polymorphic columns
        t.references :event_record, :polymorphic => true

        t.timestamps
      end
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
    
    unless table_exists?(:invitations)
      create_table :invitations do |t|
		  	t.integer  :sender_id
		  	t.string   :email, :token
		  	t.datetime :sent_at
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
    end

  end

  def self.down
    # check that each table exists before trying to delete it.
    [
      :invitations,:audit_logs, :security_questions, :sessions, 
      :simple_captcha_data, :four_oh_fours, :user_failures, 
      :logged_exceptions, :roles_users, :roles, :audit_log_items, :audit_log_item_types,
      :users, :secured_models, :roles_secured_models, :file_assets
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end
  
end
