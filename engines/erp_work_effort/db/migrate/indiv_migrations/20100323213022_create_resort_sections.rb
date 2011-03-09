class CreateResortSections < ActiveRecord::Migration
  def self.up
    create_table :resort_sections do |t|
      t.integer :resort_id

      t.timestamps
    end

    unless columns(:categories).collect {|c| c.name}.include?('category_record_id')
      add_column :categories, :category_record_id, :integer
    end

    unless columns(:categories).collect {|c| c.name}.include?('category_record_type')
      add_column :categories, :category_record_type, :string
    end
  end

  def self.down
    drop_table :resort_sections

    remove_column :categories, :category_record_id
    remove_column :categories, :category_record_type
  end
end
