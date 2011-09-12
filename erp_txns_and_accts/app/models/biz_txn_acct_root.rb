class BizTxnAcctRoot < ActiveRecord::Base

	belongs_to :biz_txn_acct, :polymorphic => true, :dependent => :destroy
	belongs_to :biz_txn_acct_type
	has_many   :biz_txn_events, :dependent => :destroy
	has_many   :biz_txn_acct_party_roles, :dependent => :destroy
	
	alias :account :biz_txn_acct
	alias :txn_events :biz_txn_events
	alias :txns :biz_txn_events
	alias :account_type :biz_txn_acct_type

	def to_label
    "#{description}"
	end
	
	def to_s
    "#{description}"
	end
	
end
