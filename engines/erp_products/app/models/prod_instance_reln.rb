class ProdInstanceReln < ActiveRecord::Base

  belongs_to :prod_instance_from, :class_name => "ProductInstance", :foreign_key => "prod_instance_id_from"  
  belongs_to :prod_instance_to, :class_name => "ProductInstance", :foreign_key => "prod_instance_id_to"
  
  belongs_to :from_role, :class_name => "ProdInstanceRoleType", :foreign_key => "role_type_id_from"
  belongs_to :to_role,   :class_name => "ProdInstanceRoleType", :foreign_key => "role_type_id_to"  
  
  belongs_to :prod_instance_reln_type
  
  alias :from_item :prod_instance_from
  alias :to_item :prod_instance_to

end
