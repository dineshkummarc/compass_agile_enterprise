Party.class_eval do

  has_many :biz_txn_acct_party_roles
	has_many :biz_txn_acct_roots, :through => :biz_txn_acct_party_roles, :dependent => :destroy
	# has_many :entity_content_assignments, :as => :da_assignment
	# has_many :credit_cards, :class_name => "CreditCard", :foreign_key => "cardholder_id"


  # Wrapper to get all party accounts
  def accounts
    biz_txn_acct_roots
  end

  # Adds a business account (BizTxnAcctPartyRole)
	def add_business_account( acct_root, biz_txn_acct_pty_rtype )
		biz_txn_acct_pty_rtype = BizTxnAcctPtyRtype.iid(biz_txn_acct_pty_rtype) if biz_txn_acct_pty_rtype.is_a? String
    raise "BizTxnAcctPtyRtype does not exist" if biz_txn_acct_pty_rtype.nil?

    apr = BizTxnAcctPartyRole.new
		apr.biz_txn_acct_pty_rtype = biz_txn_acct_pty_rtype
    biz_txn_acct_roots << acct_root
	end
end