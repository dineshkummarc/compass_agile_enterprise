class BaseTechServicesIndexes < ActiveRecord::Migration

  def self.up
    # Pre-existing indexes
    add_index :users,         :login
    add_index :roles_users,   :role_id
    add_index :roles_users,   :user_id
    add_index :user_failures, :remote_ip, :name => "btsi_1"
    #add_index :four_oh_fours, [:url, :referer], :unique => true, :name => "btsi_2" #sjk-migration There can be multiple referers in the same url
    add_index :sessions,      :session_id
    add_index :sessions,      :updated_at
    #add_index :invitations,   :token #sjk-migration An index with this name already exists in the produciton db

    add_index :users, :party_id

    ## New indexes
    add_index :users, :name
    add_index :users, :email
    add_index :users, :enabled
    
    #add_index :roles, :internal_identifier
    
    add_index :logged_exceptions, :created_at
        
    add_index :user_failures, :username
    
    add_index :simple_captcha_data, [:key, :value], :name => "btsi_3"
    
    add_index :audit_logs, :application_id
    add_index :audit_logs, :party_id
    add_index :audit_logs, :event_id
    
    add_index :invitations, :sender_id
    
    add_index :geo_countries, :name
    add_index :geo_countries, :external_id
    
    add_index :geo_zones, :geo_country_id
    
    add_index :image_assets, :parent_id
    add_index :image_assets, :filename
    
    add_index :content_mgt_assets, [:digital_asset_id, :digital_asset_type], :name => "btsi_4"
    
    add_index :entity_content_assignments, :content_mgt_asset_id
    add_index :entity_content_assignments, [:da_assignment_id, :da_assignment_type], :name => "btsi_5"
  end

  def self.down
    # Pre-existing indexes
    remove_index :users,         :login
    remove_index :roles_users,   :role_id
    remove_index :roles_users,   :user_id
    remove_index :user_failures, :name => "btsi_1"
    remove_index :four_oh_fours, :name => "btsi_2"
    remove_index :sessions,      :session_id
    remove_index :sessions,      :updated_at
    remove_index :invitations,   :token
    
    
    ## New indexes
    remove_index :users, :name
    remove_index :users, :email
    remove_index :users, :enabled

    remove_index :users, :party_id
    
    remove_index :roles, :internal_identifier
    
    remove_index :logged_exceptions, :created_at
    
    remove_index :user_failures, :username
    
    remove_index :simple_captcha_data, :name => "btsi_3"
    
    remove_index :audit_logs, :application_id
    remove_index :audit_logs, :party_id
    remove_index :audit_logs, :event_id
    
    remove_index :invitations, :sender_id
    
    remove_index :geo_countries, :name
    remove_index :geo_countries, :external_id
    
    remove_index :geo_zones, :geo_country_id
    
    remove_index :image_assets, :parent_id
    remove_index :image_assets, :filename
    
    remove_index :content_mgt_assets, :name => "btsi_4"
    
    remove_index :entity_content_assignments, :content_mgt_asset_id
    remove_index :entity_content_assignments, :name => "btsi_5"
  end
end
