class CreatePricePlanCompGlAccounts < ActiveRecord::Migration
  def self.up
    create_table :price_plan_comp_gl_accounts do |t|

      t.references  :pricing_plan_component
      t.references  :gl_account
      t.string      :mapping_rule_klass

      t.timestamps
    end
  end

  def self.down
    drop_table :price_plan_comp_gl_accounts
  end
end
