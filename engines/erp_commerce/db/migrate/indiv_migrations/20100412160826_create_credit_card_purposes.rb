class CreateCreditCardPurposes < ActiveRecord::Migration
  def self.up
    unless table_exists?(:credit_card_account_purposes)
      create_table :credit_card_account_purposes do |t|

      	t.column  :parent_id,    :integer
      	t.column  :lft,          :integer
      	t.column  :rgt,          :integer

        #custom columns go here   

      	t.column  :description,         :string
      	t.column  :comments,            :string

		    t.column 	:internal_identifier, :string
		    t.column 	:external_identifier, :string
		    t.column 	:external_id_source, 	:string

        t.timestamps
      end
    end
    
    # add purpose_id column to account table
    unless columns(:credit_card_accounts).collect {|c| c.name}.include?('credit_card_account_purpose_id')
      add_column :credit_card_accounts, :credit_card_account_purpose_id, :integer
    end
  end

  def self.down
    unless !table_exists?(:credit_card_account_purposes)
      drop_table :credit_card_account_purposes
    end
    
    unless !columns(:credit_card_accounts).collect {|c| c.name}.include?('credit_card_account_purpose_id')
      remove_column :credit_card_accounts, :credit_card_account_purpose_id 
    end
  end
end
