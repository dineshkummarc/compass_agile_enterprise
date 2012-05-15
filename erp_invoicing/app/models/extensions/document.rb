Document.class_eval do
  has_many_polymorphic :documented_models,
    :through => :valid_documents,
    :models => [:billing_account]
end