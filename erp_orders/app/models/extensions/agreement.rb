Agreement.class_eval do

  has_many_polymorphic :biz_txn_events,
               :through => :biz_txn_agreement_roles,
               :models => [:order_txns]
end