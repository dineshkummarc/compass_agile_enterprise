class AddIndexesToKnitkit < ActiveRecord::Migration
  def self.up
    add_index :website_sections, :permalink
    add_index :contents, :permalink
    add_index :website_section_contents, :content_area
  end

  def self.down
  end
end
