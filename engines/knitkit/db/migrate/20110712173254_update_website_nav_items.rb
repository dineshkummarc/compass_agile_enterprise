class UpdateWebsiteNavItems < ActiveRecord::Migration
  def self.up
    unless columns(:website_nav_items).collect {|c| c.name}.include?('linked_to_item_id')
      add_column :website_nav_items, :linked_to_item_id, :integer
      add_column :website_nav_items, :linked_to_item_type, :string

      add_index :website_nav_items, [:linked_to_item_id, :linked_to_item_type], :name => 'linked_to_idx'
    end
  end

  def self.down
    if columns(:website_nav_items).collect {|c| c.name}.include?('linked_to_item_id')
      remove_column :website_sections, :linked_to_item_id
      remove_column :website_sections, :linked_to_item_type
    end
  end
end
