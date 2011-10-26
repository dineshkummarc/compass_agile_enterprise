class AddIidToSection < ActiveRecord::Migration
  def self.up
    unless columns(:website_sections).collect {|c| c.name}.include?('internal_identifier')
      add_column :website_sections, :internal_identifier, :string

      add_column :website_section_versions, :internal_identifier, :string

      add_index :website_sections, :internal_identifier, :name => 'section_iid_idx'
    end
  end

  def self.down
    if columns(:website_sections).collect {|c| c.name}.include?('internal_identifier')
      remove_column :website_sections, :internal_identifier

      remove_column :website_section_versions, :internal_identifier

      remove_index :website_sections, :internal_identifier, :name => 'section_iid_idx'
    end
  end
end
