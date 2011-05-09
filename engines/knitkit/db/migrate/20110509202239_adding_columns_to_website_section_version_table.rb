class AddingColumnsToWebsiteSectionVersionTable < ActiveRecord::Migration
  def self.up
    unless columns(:website_section_versions).collect {|c| c.name}.include?('position')
      add_column :website_section_versions, :position, :integer
      add_index :website_section_versions, :position
    end
  end

  def self.down
    if columns(:website_section_versions).collect {|c| c.name}.include?('position')
      remove_column :website_section_versions, :position    
    end
  end
end
