class BizTxnPartyRole < ActiveRecord::Base

  belongs_to :biz_txn_event
  belongs_to :party
  belongs_to :biz_txn_party_role_type

end
