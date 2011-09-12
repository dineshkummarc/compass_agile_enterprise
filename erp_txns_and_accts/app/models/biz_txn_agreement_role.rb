class BizTxnAgreementRole < ActiveRecord::Base

	belongs_to 	:biz_txn_event, :polymorphic => true
	belongs_to 	:agreement
	belongs_to	:biz_txn_agreement_role_type
  alias       :role_type :biz_txn_agreement_role_type
end
