class AddCreditCardToAccountRoles < ActiveRecord::Migration
  def change
    unless columns(:credit_card_account_party_roles).collect {|c| c.name}.include?('credit_card_id')
      add_column :credit_card_account_party_roles, :credit_card_id, :integer
    end
  end
end
