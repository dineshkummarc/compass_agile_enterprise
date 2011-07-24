Agreement.class_eval do

  has_morpheus :biz_txn_events,
               :through => :biz_txn_agreement_roles,
               :models => [:order_txns]
end