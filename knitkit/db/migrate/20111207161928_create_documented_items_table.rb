class CreateDocumentedItemsTable < ActiveRecord::Migration
  def self.up
    create_table :documented_items, :force => true do |t|
      t.string :documented_klass, :null => true
      t.integer :documented_content_id, :null => true
      t.timestamps
    end
  end

  def self.down
    drop_table :documented_items
  end
end