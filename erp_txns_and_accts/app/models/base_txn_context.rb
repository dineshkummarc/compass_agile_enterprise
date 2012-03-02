class BaseTxnContext < ActiveRecord::Base

  belongs_to  :txn_context_record, :polymorphic => true
  belongs_to  :biz_txn_event

end
