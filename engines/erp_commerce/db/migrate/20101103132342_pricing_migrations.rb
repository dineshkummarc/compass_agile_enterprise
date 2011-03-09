class PricingMigrations < ActiveRecord::Migration
  def self.up

    #tables
    unless table_exists?(:price_component_types)
      create_table :price_component_types do |t|

        t.string      :description
        t.string      :internal_identifier
        t.string      :external_identifier
        t.string      :external_id_source

        t.timestamps
      end
    end

    unless table_exists?(:pricing_plans)
      create_table :pricing_plans do |t|

        t.string  :description
        t.string  :comments

        t.string 	:internal_identifier

        t.string 	:external_identifier
        t.string 	:external_id_source

        #this is here as a placeholder for an 'interpreter' or 'rule' pattern
        t.string  :matching_rules
        #this is here as a placeholder for an 'interpreter' or 'rule' pattern
        t.string  :pricing_calculation

        #support for simple assignment of a single money amount
        t.boolean :is_simple_amount
        t.integer :currency_id
        t.float   :money_amount

        t.timestamps
      end
    end

    unless table_exists?(:pricing_plan_components)
      create_table :pricing_plan_components do |t|

        t.integer :price_component_type_id
        t.string  :description
        t.string  :comments

        t.string 	:internal_identifier
        t.string 	:external_identifier
        t.string 	:external_id_source


        #this is here as a placeholder for an 'interpreter' or 'rule' pattern
        t.string  :matching_rules
        #this is here as a placeholder for an 'interpreter' or 'rule' pattern
        t.string  :pricing_calculation

        #support for simple assignment of a single money amount
        t.boolean :is_simple_amount
        t.integer :currency_id
        t.float   :money_amount

        t.timestamps

      end
      add_index :pricing_plan_components, :price_component_type_id
    end

    unless table_exists?(:valid_price_plan_components)
      create_table :valid_price_plan_components do |t|

        t.references  :pricing_plan
        t.references  :pricing_plan_component

        t.timestamps

      end
      add_index :valid_price_plan_components, :pricing_plan_id
      add_index :valid_price_plan_components, :pricing_plan_component_id
    end

    unless table_exists?(:pricing_plan_assignments)
      create_table :pricing_plan_assignments do |t|

        t.references  :pricing_plan

        #support a polymorhic interface to the thing we want to price
        t.integer     :priceable_item_id
        t.string      :priceable_item_type

        t.integer     :priority

        t.timestamps

      end
      add_index :pricing_plan_assignments, :pricing_plan_id
      add_index :pricing_plan_assignments, [:priceable_item_id,:priceable_item_type]
    end
   
    unless table_exists?(:prices)
      create_table :prices do |t|
  
        t.string      :description
  
        #support a polymorhic interface to the thing that HAS BEEN priced
        t.integer     :priced_item_id
        t.string      :priced_item_type
  
        #refer to the pricing plan by which this price was calculated
        t.references  :pricing_plan
  
        t.references  :money
  
        t.timestamps

      end
      add_index :prices, :money_id
      add_index :prices, :pricing_plan_id
      add_index :prices, [:priced_item_id,:priced_item_type]
    end

    unless table_exists?(:price_components)
      create_table :price_components do |t|

        t.string      :description
        t.references  :pricing_plan_component
        t.references  :price
        t.references  :money

        #polymorphic relationship
        t.integer :priced_component_id
        t.string  :priced_component_type

        t.timestamps

      end
      add_index :price_components, :money_id
      add_index :price_components, :pricing_plan_component_id
      add_index :price_components, :price_id
      add_index :price_components, [:priced_component_id,:priced_component_type]
    end

  end
       

  def self.down
    
    #tables
    drop_tables = [
      :pricing_plans,
      :pricing_plan_components,
      :valid_price_plan_components,  
      :pricing_plan_assignments,
      :prices,
      :price_components,
      :price_component_types
    ]
    drop_tables.each do |table|
      if table_exists?(table)
        drop_table table
      end
    end    
    
  end
end
