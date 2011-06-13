Party.class_eval do

  has_many :biz_txn_acct_party_roles
	has_many :biz_txn_acct_roots, :through => :biz_txn_acct_party_roles, :dependent => :destroy
	# has_many :entity_content_assignments, :as => :da_assignment
	# has_many :credit_cards, :class_name => "CreditCard", :foreign_key => "cardholder_id"


  # Wrapper to get all party accounts
  def accounts
    relationships

    # old call:
    #biz_txn_acct_roots

    # TODO: Get data so we can use this optimized version:
    #BizTxnAcctPartyRole.find(:all, :joins => [:party, :biz_txn_acct_root, :biz_txn_acct_pty_rtype], :conditions => ['party_id =?', id])
  end

  # Adds a business account (BizTxnAcctPartyRole)
	def add_business_account( acct_root, role_type_id = 10000 )
		apr = BizTxnAcctPartyRole.new

		apr.biz_txn_acct_pty_rtype = BizTxnAcctPtyRtype.find(role_type_id)
    biz_txn_acct_roots << acct_root
	end
end