Agreement.class_eval do
  has_many_polymorphs	:biz_txn_events, :through => :biz_txn_agreement_roles, :from => [:order_txns]
end