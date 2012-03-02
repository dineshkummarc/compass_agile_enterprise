class UpdateContents < ActiveRecord::Migration
  def self.up
    unless columns(:contents).collect {|c| c.name}.include?('display_title')
      add_column :contents, :display_title, :boolean
      add_column :contents, :internal_identifier, :string

      add_column :content_versions, :display_title, :boolean
      add_column :content_versions, :internal_identifier, :string

      add_index :contents, :internal_identifier, :name => 'contents_iid_idx'
    end
  end

  def self.down
    if columns(:contents).collect {|c| c.name}.include?('display_title')
      remove_column :contents, :display_title
      remove_column :contents, :internal_identifier

      remove_column :content_versions, :display_title
      remove_column :content_versions, :internal_identifier

      remove_index :contents, :name => 'contents_iid_idx'
    end
  end
end
