class BaseProductsIndexes < ActiveRecord::Migration
  def self.up
    add_index :product_types, :parent_id
    add_index :product_types, [:product_type_record_id, :product_type_record_type], 
              :name => "bpi_1"

    add_index :product_instances, :parent_id
    add_index :product_instances, [:product_instance_record_id, :product_instance_record_type], 
              :name => "bpi_2"
    add_index :product_instances, :product_type_id
    
    add_index :product_offers, [:product_offer_record_id, :product_offer_record_type], 
              :name => "bpi_3"
    
    add_index :simple_product_offers, :product_id
    
    add_index :prod_instance_reln_types, :parent_id
    
    add_index :prod_instance_role_types, :parent_id
    
    add_index :prod_instance_relns, :prod_instance_reln_type_id
    add_index :prod_instance_relns, :status_type_id
    
    add_index :prod_type_reln_types, :parent_id
    
    add_index :prod_type_role_types, :parent_id
    
    add_index :prod_type_relns, :prod_type_reln_type_id
    add_index :prod_type_relns, :status_type_id
  end

  def self.down
    remove_index :product_types, :parent_id
    remove_index :product_types, :name => "bpi_1"

    remove_index :product_instances, :parent_id
    remove_index :product_instances, :name => "bpi_2"
    remove_index :product_instances, :product_type_id
    
    remove_index :product_offers, :name => "bpi_3"
    
    remove_index :simple_product_offers, :product_id
    
    remove_index :prod_instance_reln_types, :parent_id
    
    remove_index :prod_instance_role_types, :parent_id
    
    remove_index :prod_instance_relns, :prod_instance_reln_type_id
    remove_index :prod_instance_relns, :status_type_id
    
    remove_index :prod_type_reln_types, :parent_id
    
    remove_index :prod_type_role_types, :parent_id
    
    remove_index :prod_type_relns, :prod_type_reln_type_id
    remove_index :prod_type_relns, :status_type_id
  end
end
