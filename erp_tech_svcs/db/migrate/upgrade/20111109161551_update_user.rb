class UpdateUser < ActiveRecord::Migration
  def up
    unless columns(:users).collect {|c| c.name}.include?('activation_state')

      #have to move over current users
      current_users = []
      User.all.each do |user|
        current_users << {
          :enabled => user.enabled,
          :email => user.email
        }
      end

      #change_columns
      change_column :users, :salt, :string
      change_column :users, :crypted_password, :string

      #remove old columns
      remove_column :users, :name
      remove_column :users, :activated_at
      remove_column :users, :enabled
      remove_column :users, :identity_url
      remove_column :users, :invitation_id
      remove_column :users, :invitation_limit
      remove_column :users, :club_number
      remove_column :users, :owner_number
      remove_column :users, :dob
      remove_column :users, :ssn_last_four
      remove_column :users, :salutation
      remove_column :users, :first_name
      remove_column :users, :last_name
      remove_column :users, :street_address
      remove_column :users, :city
      remove_column :users, :state_province
      remove_column :users, :postal_code
      remove_column :users, :country
      remove_column :users, :phone
      remove_column :users, :security_question_1
      remove_column :users, :security_answer_1
      remove_column :users, :security_question_2
      remove_column :users, :security_answer_2

      #rename columns
      rename_column :users, :remember_token, :remember_me_token
      rename_column :users, :remember_token_expires_at, :remember_me_token_expires_at
      rename_column :users, :activation_code, :activation_token
      rename_column :users, :activation_code_expires_at, :activation_token_expires_at
      rename_column :users, :password_reset_code, :password_reset_token
      rename_column :users, :lock_count, :failed_logins_count
      rename_column :users, :login, :username

      if columns(:users).collect {|c| c.name}.include?('user_type')
        rename_column :users, :user_type, :type
      end

      #activity logging
      add_column :users, :last_login_at,     :datetime, :default => nil
      add_column :users, :last_logout_at,    :datetime, :default => nil
      add_column :users, :last_activity_at,  :datetime, :default => nil
      add_index :users, [:last_logout_at, :last_activity_at], :name => 'activity_idx'

      #brute force protection
      add_column :users, :lock_expires_at, :datetime, :default => nil

      #reset password
      add_column :users, :reset_password_token, :datetime, :default => nil
      add_column :users, :reset_password_token_expires_at, :datetime, :default => nil
      add_column :users, :reset_password_email_sent_at, :datetime, :default => nil

      #user activation
      add_column :users, :activation_state, :string, :default => nil

      current_users.each do |user_hash|
        if user_hash[:enabled]
          User.reset_column_information
          user = User.find_by_email(user_hash[:email])
          user.activate!
          user.password_confirmation = 'password'
          user.change_password!('password')
        end
      end
      
    end
  end

  def down
  end
end
