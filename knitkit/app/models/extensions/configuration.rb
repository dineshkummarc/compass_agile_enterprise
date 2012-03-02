::Configuration.class_eval do
  has_many_polymorphic :configured_items,
    :through => :valid_configurations,
    :models => [:websites]
end