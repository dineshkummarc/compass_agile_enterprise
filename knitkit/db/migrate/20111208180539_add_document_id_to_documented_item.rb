class AddDocumentIdToDocumentedItem < ActiveRecord::Migration
  def self.up
    add_column :documented_items, :online_document_section_id, :integer
  end

  def self.down
    remove_column :documented_items, :online_document_section_id
  end
end