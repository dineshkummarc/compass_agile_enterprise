class CreateBizTxnAgreementRoles < ActiveRecord::Migration
  def self.up
    create_table :biz_txn_agreement_roles do |t|

        t.references  :biz_txn_event,                   :polymorphic => true
        t.column      :agreement_id,                    :integer
        t.column      :biz_txn_agreement_role_type_id,  :integer
        t.timestamps

    end
  end

  def self.down
    drop_table :biz_txn_agreement_roles
  end
end
