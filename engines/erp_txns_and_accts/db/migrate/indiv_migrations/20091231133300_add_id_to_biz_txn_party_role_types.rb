class AddIdToBizTxnPartyRoleTypes < ActiveRecord::Migration

  def self.up
    add_column :biz_txn_party_role_types, :internal_identifier, :string

  end

  def self.down
    remove_column :biz_txn_party_role_types, :internal_identifier
  end

end
