class BizTxnAcctPtyRtype < ActiveRecord::Base
  acts_as_nested_set
  acts_as_erp_type

  has_many :biz_txn_acct_party_roles

end
