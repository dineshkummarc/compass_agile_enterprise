class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :description
      t.string :external_identifier
      t.DateTime :from_date
      t.DateTime :to_date
      t.string :internal_identifier

      t.timestamps
    end
  end

  def self.down
    drop_table :categories
  end
end
