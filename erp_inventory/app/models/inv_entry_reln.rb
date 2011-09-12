class InvEntryReln < ActiveRecord::Base

  belongs_to :inv_entry_from, :class_name => "InvEntry", :foreign_key => "inv_entry_id_from"  
  belongs_to :inv_entry_to, :class_name => "InvEntry", :foreign_key => "inv_entry_id_to"
  
  belongs_to :from_role, :class_name => "InvEntryRoleType", :foreign_key => "role_type_id_from"
  belongs_to :to_role,   :class_name => "InvEntryRoleType", :foreign_key => "role_type_id_to"  
  
  belongs_to :inv_entry_reln_type
  
  alias :from_item :inv_entry_from
  alias :to_item :inv_entry_to  
  
end
