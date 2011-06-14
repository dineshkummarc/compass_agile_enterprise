class AgreementsServicesIndexes < ActiveRecord::Migration
  def self.up
    add_index :agreements, :agreement_type_id
    add_index :agreements, :product_id
    
    add_index :agreement_types, :parent_id
    
    add_index :agreement_items, :agreement_id
    add_index :agreement_items, :agreement_item_type_id
    
    add_index :agreement_item_types, :parent_id
    
    add_index :agreement_party_roles, :agreement_id
    add_index :agreement_party_roles, :party_id
    add_index :agreement_party_roles, :role_type_id
    
    add_index :agreement_relationships, :agreement_reln_type_id
    add_index :agreement_relationships, :status_type_id
    
    add_index :agreement_reln_types, :parent_id
    add_index :agreement_reln_types, :valid_from_role_type_id
    add_index :agreement_reln_types, :valid_to_role_type_id

    add_index :agreement_role_types, :parent_id
  end

  def self.down
    remove_index :agreements, :agreement_type_id
    remove_index :agreements, :product_id
    
    remove_index :agreement_types, :parent_id
    
    remove_index :agreement_items, :agreement_id
    remove_index :agreement_items, :agreement_item_type_id
    
    remove_index :agreement_item_types, :parent_id
    
    remove_index :agreement_party_roles, :agreement_id
    remove_index :agreement_party_roles, :party_id
    remove_index :agreement_party_roles, :role_type_id
    
    remove_index :agreement_relationships, :agreement_reln_type_id
    remove_index :agreement_relationships, :status_type_id
    
    remove_index :agreement_reln_types, :parent_id
    remove_index :agreement_reln_types, :valid_from_role_type_id
    remove_index :agreement_reln_types, :valid_to_role_type_id

    remove_index :agreement_role_types, :parent_id
  end
end
