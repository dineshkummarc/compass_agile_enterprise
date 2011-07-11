ProductInstance.class_eval do
  
  # A ProductInstance can be referenced by more than one inventory entry via overbooking or
	# "first-come, first serve" inventory strategies. This is a cross-reference entity that
	# allows this kind of relationship, which is optional depending on business circumstances.
  has_many :prod_instance_inv_entries
  has_many :inventory_entries, :through => :prod_instance_inv_entries
  
end
