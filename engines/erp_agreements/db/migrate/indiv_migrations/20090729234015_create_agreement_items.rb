class CreateAgreementItems < ActiveRecord::Migration
  def self.up
    create_table :agreement_items do |t|

      t.column  :agreement_id,                :integer
      t.column  :agreement_item_type_id,      :integer
      t.column  :agreement_item_value,        :string
      t.column  :description,                 :string
      t.column  :agreement_item_rule_string,  :string

      t.timestamps

    end
  end

  def self.down
    drop_table :agreement_items
  end
end
