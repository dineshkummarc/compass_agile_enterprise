class RenameRtypeIdInBizTxnPtyRtypes < ActiveRecord::Migration

  def self.up

    rename_column :biz_txn_party_roles, :role_type_id, :biz_txn_party_role_type_id

  end

  def self.down

    rename_column :biz_txn_party_roles, :biz_txn_party_role_type_id, :role_type_id

  end

end
