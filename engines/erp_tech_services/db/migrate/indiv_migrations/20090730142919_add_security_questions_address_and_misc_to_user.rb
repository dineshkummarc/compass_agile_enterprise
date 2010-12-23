class AddSecurityQuestionsAddressAndMiscToUser < ActiveRecord::Migration
  def self.up
 
    add_column :users, :club_number, :string
    add_column :users, :owner_number, :string
    add_column :users, :dob, :date
    add_column :users, :ssn_last_four, :string

    add_column :users, :salutation, :string
    add_column :users, :first_name,  :string
    add_column :users, :last_name, :string

    add_column :users, :street_address, :string
    add_column :users, :city, :string
    add_column :users, :state_province, :string
    add_column :users, :postal_code, :string
    add_column :users, :country, :string
    add_column :users, :phone, :string


    add_column :users, :security_question_1, :string
    add_column :users, :security_answer_1, :string
   
    add_column :users, :security_question_2, :string
    add_column :users, :security_answer_2, :string  

  end

  def self.down
    remove_column :users, 'club_number'
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
  end
end
