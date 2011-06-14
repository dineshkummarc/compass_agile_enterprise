class AddAutoActivatePublicationColumn < ActiveRecord::Migration
  def self.up
    unless columns(:websites).collect {|c| c.name}.include?('auto_activate_publication')
      add_column :websites, :auto_activate_publication, :boolean
    end
  end

  def self.down
    if columns(:websites).collect {|c| c.name}.include?('auto_activate_publication')
      remove_column :websites, :auto_activate_publication
    end
  end
end
