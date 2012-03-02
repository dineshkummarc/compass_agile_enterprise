class AddIidToWebsites < ActiveRecord::Migration
  def up
    unless columns(:websites).collect {|c| c.name}.include?('internal_identifier')
      add_column :websites, :internal_identifier, :string
      add_index :websites, :internal_identifier
    end
  end

  def down
    if columns(:websites).collect {|c| c.name}.include?('internal_identifier')
      remove_column :websites, :internal_identifier
    end
  end
end
