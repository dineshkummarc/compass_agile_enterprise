class RemoveAllowInquries < ActiveRecord::Migration
  def self.up
    if columns(:websites).collect {|c| c.name}.include?('allow_inquries')
      remove_column :websites, :allow_inquries
    end
  end

  def self.down
    unless columns(:websites).collect {|c| c.name}.include?('allow_inquries')
      add_column :websites, :allow_inquries, :boolean
    end
  end
end
