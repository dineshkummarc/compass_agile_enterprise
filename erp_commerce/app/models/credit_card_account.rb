class CreditCardAccount < ActiveRecord::Base
  acts_as_biz_txn_account
  belongs_to :credit_card_account_purpose
end
