class CreateCategoryClassifications < ActiveRecord::Migration
  def self.up
    create_table :category_classifications do |t|
      t.integer :category_id
      t.string :classification_type
      t.integer :classification_id
      t.DateTime :from_date
      t.DateTime :to_date

      t.timestamps
    end
  end

  def self.down
    drop_table :category_classifications
  end
end
