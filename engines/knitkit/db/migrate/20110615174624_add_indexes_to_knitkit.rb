class AddIndexesToKnitkit < ActiveRecord::Migration
  def self.up
    unless indexes(:website_sections).collect {|i| i.name}.include?('index_website_sections_on_permalink')
      add_index :website_sections, :permalink
    end
    unless indexes(:contents).collect {|i| i.name}.include?('index_contents_on_permalink')
      add_index :contents, :permalink
    end
    unless indexes(:website_section_contents).collect {|i| i.name}.include?('index_website_section_contents_on_content_area')
      add_index :website_section_contents, :content_area
    end
  end

  def self.down
  end
end
