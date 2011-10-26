class AddPublishedByToPublishedElements < ActiveRecord::Migration
  def self.up
    unless columns(:published_websites).collect {|c| c.name}.include?('published_by_id')
      add_column :published_websites, :published_by_id, :integer
      add_index :published_websites, :published_by_id
    end

    unless columns(:published_elements).collect {|c| c.name}.include?('published_by_id')
      add_column :published_elements, :published_by_id, :integer
      add_index :published_elements, :published_by_id
    end
  end

  def self.down
    if columns(:published_websites).collect {|c| c.name}.include?('published_by_id')
      remove_column :published_websites, :published_by_id
    end
    if columns(:published_elements).collect {|c| c.name}.include?('published_by_id')
      remove_column :published_elements, :published_by_id
    end
  end
end
