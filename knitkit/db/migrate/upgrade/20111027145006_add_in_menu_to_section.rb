class AddInMenuToSection < ActiveRecord::Migration
  def self.up
    unless columns(:website_sections).collect {|c| c.name}.include?('in_menu')
      add_column :website_sections, :in_menu, :boolean
    end
    unless columns(:website_section_versions).collect {|c| c.name}.include?('in_menu')
      add_column :website_section_versions, :in_menu, :boolean
    end
  end

  def self.down
    if columns(:website_sections).collect {|c| c.name}.include?('in_menu')
      remove_column :website_sections, :in_menu
    end
    if columns(:website_section_versions).collect {|c| c.name}.include?('in_menu')
      remove_column :website_section_versions, :in_menu
    end
  end
end
