class BizTxnAcctPartyRole < ActiveRecord::Base

	belongs_to :biz_txn_acct_root
	belongs_to :party
	belongs_to :biz_txn_acct_pty_rtype
	
	def role_type
		biz_txn_acct_pty_rtype
	end
	
	def account_root
		biz_txn_acct_root
	end
	
	def to_label
        "#{party.description}:#{role_type.description}"
	end
	
	def description
        "#{party.description}:#{role_type.description}"
	end

end
