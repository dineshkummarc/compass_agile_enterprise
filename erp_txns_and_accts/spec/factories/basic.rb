##
#The basic models, these factories have no
#callbacks, associations, sequences declared
#besides what's necessary
FactoryGirl.define do
  factory :financial_txn
  factory :financial_txn_account
  factory :biz_txn_acct_root
  factory :biz_txn_event
  factory :biz_txn_acct
  factory :biz_txn_acct_party_role
  factory :biz_txn_type
end
