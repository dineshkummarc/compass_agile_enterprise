class FinancialAccountingServices < ActiveRecord::Migration
  def self.up

    unless table_exists?(:gl_accounts)
      create_table :gl_accounts do |t|

        #these columns are required to support the behavior of the plugin 'better_nested_set'
        t.column  	:parent_id,    :integer
        t.column  	:lft,          :integer
        t.column  	:rgt,          :integer

        #custom columns go here   
        t.column  	:description, :string
        t.column  	:comments, :string
		    t.column 	:internal_identifier, 	:string
		    t.column 	:external_identifier, 	:string
		    t.column 	:external_id_source, 	:string

        t.timestamps
      
      end
    end

    unless table_exists?(:price_plan_comp_gl_accounts)
      create_table :price_plan_comp_gl_accounts do |t|

        t.references  :pricing_plan_component
        t.references  :gl_account
        t.string      :mapping_rule_klass

        t.timestamps
      end
    end

  end

  def self.down

    [
      :gl_accounts, :price_plan_comp_gl_accounts
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end
  
end

