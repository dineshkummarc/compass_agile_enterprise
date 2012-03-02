class SearchTxnContext < ActiveRecord::Base

  has_one :base_txn_context, :as => :txn_context_record

  def after_create
    base_txn_context = BaseTxnContext.new
    base_txn_context.txn_context_record  = self
    base_txn_context.save
  end

end
