class CreateBizTxnAgreementRoleTypes < ActiveRecord::Migration
  def self.up
    create_table :biz_txn_agreement_role_types do |t|

      t.column  :parent_id,    :integer
      t.column  :lft,          :integer
      t.column  :rgt,          :integer

    #custom columns go here

      t.column  :description, :string
      t.column  :comments, :string

      t.timestamps

    end
  end

  def self.down
    drop_table :biz_txn_agreement_role_types
  end
end
