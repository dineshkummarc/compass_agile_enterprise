class AddRenderBaseLayoutFlag < ActiveRecord::Migration
  def self.up
    unless columns(:website_sections).collect {|c| c.name}.include?('render_base_layout')
      add_column :website_sections, :render_base_layout, :string, :default => true
    end
  end

  def self.down
    if columns(:website_sections).collect {|c| c.name}.include?('render_base_layout')
      remove_column :website_sections, :render_base_layout
    end
  end
end
