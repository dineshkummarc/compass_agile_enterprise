class UpdateDescriptiveAsset < ActiveRecord::Migration
  def self.up
    change_table :descriptive_assets do |t|
      t.change :description, :text
    end
  end

  def self.down
    change_table :descriptive_assets do |t|
      t.change :description, :string
    end
  end
end
