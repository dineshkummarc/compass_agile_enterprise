class AddCreatedUpdatedByToContents < ActiveRecord::Migration
  def self.up
    unless columns(:contents).collect {|c| c.name}.include?('created_by_id')
      add_column :contents, :created_by_id, :integer
      add_index :contents, :created_by_id
    end
    unless columns(:contents).collect {|c| c.name}.include?('updated_by_id')
      add_column :contents, :updated_by_id, :integer
      add_index :contents, :updated_by_id
    end

    unless columns(:content_versions).collect {|c| c.name}.include?('created_by_id')
      add_column :content_versions, :created_by_id, :integer
      add_index :content_versions, :created_by_id
    end
    unless columns(:content_versions).collect {|c| c.name}.include?('updated_by_id')
      add_column :content_versions, :updated_by_id, :integer
      add_index :content_versions, :updated_by_id
    end
  end

  def self.down
    if columns(:contents).collect {|c| c.name}.include?('created_by_id')
      remove_column :contents, :created_by_id
    end
    if columns(:contents).collect {|c| c.name}.include?('updated_by_id')
      remove_column :contents, :updated_by_id
    end
    if columns(:content_versions).collect {|c| c.name}.include?('created_by_id')
      remove_column :content_versions, :created_by_id
    end
    if columns(:content_versions).collect {|c| c.name}.include?('updated_by_id')
      remove_column :content_versions, :updated_by_id
    end
  end
end
