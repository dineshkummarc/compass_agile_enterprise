class OrderLineItemPtyRole < ActiveRecord::Base

#***************************************************************************
# Who's booking? Who's staying? Who's paying? These role types can be
# played by different people by implementing this structure
#***************************************************************************

  belongs_to  :order_line_item
  belongs_to  :party
  belongs_to  :line_item_role_type

#***************************************************************************
# The association of a transaction to an account happens in the context of
# the Party, the Role that they're playing in this Transaction and the type
# of Transaction - we call this process Guiding a Transaction to an Account.
#
# It's an important process and it's handled by a TransactionRulesManager,
# which is so named to distinguish it from Transaction Managment Software
# like Tuxedo.
# In this case, we have an optional account reference here so that orders
# can be split across accounts.
#***************************************************************************  
  
  belongs_to  :bix_txn_acct_root

  def to_label
    "#{party.description}"
  end
  
  def description
    "#{party.description}"
  end
	

end
