class RenameChrgdItemsColsInChrgLines < ActiveRecord::Migration

  def self.up

    rename_column :charge_lines, :charged_items_id, :charged_item_id
    rename_column :charge_lines, :charged_items_type, :charged_item_type

  end

  def self.down

    rename_column :charge_lines, :charged_item_id, :charged_items_id
    rename_column :charge_lines, :charged_item_type, :charged_items_type

  end

end
