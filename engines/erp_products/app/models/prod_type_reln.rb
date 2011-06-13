class ProdTypeReln < ActiveRecord::Base

  belongs_to :prod_type_from, :class_name => "ProductType", :foreign_key => "prod_type_id_from"
  belongs_to :prod_type_to, :class_name => "ProductType", :foreign_key => "prod_type_id_to"
  
  belongs_to :from_role, :class_name => "ProdTypeRoleType", :foreign_key => "role_type_id_from"
  belongs_to :to_role,   :class_name => "ProdTypeRoleType", :foreign_key => "role_type_id_to"  
  
  belongs_to :prod_type_reln_type
  
  alias :from_item :prod_type_from
  alias :to_item :prod_type_to 
  
  
end
