class BizTxnAcctRoot < ActiveRecord::Base

	belongs_to :biz_txn_acct, :polymorphic => true
	has_many   :biz_txn_events, :dependent => :destroy
	has_many   :biz_txn_acct_party_roles, :dependent => :destroy
	
	alias :account :biz_txn_acct
	alias :txn_events :biz_txn_events
	alias :txns :biz_txn_events

	def to_label
    "#{description}"
	end
	
	def to_s
    "#{description}"
	end

  def add_party_with_role(party, biz_txn_acct_pty_rtype, description=nil)
    biz_txn_acct_pty_rtype = BizTxnAcctPtyRtype.iid(biz_txn_acct_pty_rtype) if biz_txn_acct_pty_rtype.is_a? String
    raise "BizTxnAcctPtyRtype does not exist" if biz_txn_acct_pty_rtype.nil?

    self.biz_txn_acct_party_roles << BizTxnAcctPartyRole.create(:party => party, :description => description, :biz_txn_acct_pty_rtype => biz_txn_acct_pty_rtype)
    self.save
  end

  def find_parties_by_role(biz_txn_acct_pty_rtype)
    biz_txn_acct_pty_rtype = BizTxnAcctPtyRtype.iid(biz_txn_acct_pty_rtype) if biz_txn_acct_pty_rtype.is_a? String
    raise "BizTxnAcctPtyRtype does not exist" if biz_txn_acct_pty_rtype.nil?
    self.biz_txn_acct_party_roles.where('biz_txn_acct_pty_rtype_id = ?', biz_txn_acct_pty_rtype.id).collect(&:party)
  end
	
end
